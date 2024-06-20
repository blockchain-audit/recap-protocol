// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../interfaces/ITrade.sol";

import "./ViewFuncTrade.sol";

contract Trade is ITrade , ViewFuncTrade{

    
    // Modifiers
    modifier onlyGov() {
        require(msg.sender == stateTrade.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        stateTrade.gov = _gov;
    }

    // Gov methods
    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = stateTrade.gov;
        stateTrade.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _chainlink, address _pool, address _store) external onlyGov {
        stateTrade.chainlink = IChainlink(_chainlink);
        stateTrade.pool = IPool(_pool);
        stateTrade.store = IStore(_store);
    }

    // Deposit / Withdraw logic

    function deposit(uint256 amount) external {
        require(amount > 0, "!amount");
        stateTrade.store.transferIn(msg.sender, amount);
        stateTrade.store.incrementBalance(msg.sender, amount);
        emit Deposit(msg.sender, amount);
    }

    function depositThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited in the store contract
        uint256 amountOut = stateTrade.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        stateTrade.store.incrementBalance(msg.sender, amountOut);

        emit Deposit(msg.sender, amountOut);
    }

    function withdraw(uint256 amount) external {
        address user = msg.sender;

        // if amount to withdraw > balance, set it to balance
        uint256 balance = stateTrade.storeView.getBalance(user);
        if (amount > balance) amount = balance;

        // equity after withdraw
        int256 upl = getUpl(user);
        uint256 lockedMargin = stateTrade.storeView.getLockedMargin(user);
        int256 equity = int256(balance - amount) + upl; 

        // adjust amount if equity after withdrawing < lockedMargin
        if (equity < int256(lockedMargin)) {
            int256 maxWithdrawableAmount;
            maxWithdrawableAmount = int256(balance) - int256(lockedMargin) + upl;

            if (maxWithdrawableAmount < 0) amount = 0;
            else amount = uint256(maxWithdrawableAmount);
        }

        require(amount > 0, "!amount > 0");
        // this should never trigger, but we keep it in as fail safe
        require(int256(lockedMargin) <= int256(balance - amount) + upl, "!equity");

        stateTrade.store.decrementBalance(user, amount);
        stateTrade.store.transferOut(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    // Order logic
    function submitOrder(IStore.Order memory params, uint256 tpPrice, uint256 slPrice) external {
        address user = msg.sender;

        IStore.Market memory market = stateTrade.storeView.getMarket(params.market);
        require(market.maxLeverage > 0, "!market");

        if (params.isReduceOnly) {
            params.margin = 0;
        } else {
            params.margin = params.size / market.maxLeverage;

            // check equity
            int256 upl = getUpl(user);
            uint256 balance = stateTrade.storeView.getBalance(user);
            int256 equity = int256(balance) + upl;

            uint256 lockedMargin = stateTrade.storeView.getLockedMargin(user);
            require(int256(lockedMargin) <= equity, "!equity");

            // if margin exceeds freeMargin, set it to max freeMargin available
            if (int256(lockedMargin + params.margin) > equity) {
                params.margin = uint256(equity - int256(lockedMargin));
                // adjust size so leverage stays the same
                params.size = market.maxLeverage * params.margin;
            }

            require(params.margin > 0 && int256(lockedMargin + params.margin) <= equity, "!margin");
            stateTrade.store.lockMargin(user, params.margin);
        }

        // size should be above market.minSize
        require(market.minSize <= params.size, "!min-size");

        // fee
        uint256 fee = market.fee * params.size / BPS_DIVIDER;
        stateTrade.store.decrementBalance(user, fee);

        // Get chainlink price
        uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
        require(chainlinkPrice > 0, "!chainlink");

        // Check chainlink price vs order price for trigger orders
        if (
            params.orderType == 1 && params.isLong && chainlinkPrice <= params.price
                || params.orderType == 1 && !params.isLong && chainlinkPrice >= params.price
                || params.orderType == 2 && params.isLong && chainlinkPrice >= params.price
                || params.orderType == 2 && !params.isLong && chainlinkPrice <= params.price
        ) {
            revert("!orderType");
        }

        // Assign current chainlink price to market orders
        if (params.orderType == 0) {
            params.price = chainlinkPrice;
        }

        // Save order to store
        params.user = user;
        params.fee = uint192(fee);
        params.timestamp = uint64(block.timestamp);

        uint256 orderId = stateTrade.store.addOrder(params);

        emit OrderCreated(
            orderId,
            params.user,
            params.market,
            params.isLong,
            params.margin,
            params.size,
            params.price,
            params.fee,
            params.orderType,
            params.isReduceOnly
            );

        if (tpPrice > 0) {
            IStore.Order memory tpOrder = IStore.Order({
                orderId: 0,
                user: user,
                market: params.market,
                price: tpPrice,
                isLong: !params.isLong,
                isReduceOnly: true,
                orderType: 1,
                margin: 0,
                size: params.size,
                fee: params.fee,
                timestamp: uint64(block.timestamp)
            });
            stateTrade.store.decrementBalance(user, fee);
            uint256 tpOrderId = stateTrade.store.addOrder(tpOrder);
            emit OrderCreated(
                tpOrderId,
                tpOrder.user,
                tpOrder.market,
                tpOrder.isLong,
                tpOrder.margin,
                tpOrder.size,
                tpOrder.price,
                tpOrder.fee,
                tpOrder.orderType,
                tpOrder.isReduceOnly
                );
        }

        if (slPrice > 0) {
            IStore.Order memory slOrder = IStore.Order({
                orderId: 0,
                user: user,
                market: params.market,
                price: slPrice,
                isLong: !params.isLong,
                isReduceOnly: true,
                orderType: 2,
                margin: 0,
                size: params.size,
                fee: params.fee,
                timestamp: uint64(block.timestamp)
            });
            stateTrade.store.decrementBalance(user, fee);
            uint256 slOrderId = stateTrade.store.addOrder(slOrder);
            emit OrderCreated(
                slOrderId,
                slOrder.user,
                slOrder.market,
                slOrder.isLong,
                slOrder.margin,
                slOrder.size,
                slOrder.price,
                slOrder.fee,
                slOrder.orderType,
                slOrder.isReduceOnly
                );
        }
    }

    function updateOrder(uint256 orderId, uint256 price) external {
        IStore.Order memory order = stateTrade.storeView.getOrder(orderId);
        require(order.user == msg.sender, "!user");
        require(order.size > 0, "!order");
        require(order.orderType != 0, "!market-order");

        IStore.Market memory market = stateTrade.storeView.getMarket(order.market);
        uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
        require(chainlinkPrice > 0, "!chainlink");

        if (
            order.orderType == 1 && order.isLong && chainlinkPrice <= price
                || order.orderType == 1 && !order.isLong && chainlinkPrice >= price
                || order.orderType == 2 && order.isLong && chainlinkPrice >= price
                || order.orderType == 2 && !order.isLong && chainlinkPrice <= price
        ) {
            if (order.orderType == 1) order.orderType = 2;
            else order.orderType = 1;
        }

        order.price = price;
        stateTrade.store.updateOrder(order);
    }

    function cancelOrders(uint256[] calldata orderIds) external {
        for (uint256 i = 0; i < orderIds.length; i++) {
            cancelOrder(orderIds[i]);
        }
    }

    function cancelOrder(uint256 orderId) public {
        IStore.Order memory order = stateTrade.storeView.getOrder(orderId);
        require(order.user == msg.sender, "!user");
        require(order.size > 0, "!order");
        _cancelOrder(orderId);
    }

    function _cancelOrder(uint256 orderId) internal {
        IStore.Order memory order = stateTrade.storeView.getOrder(orderId);

        if (!order.isReduceOnly) {
            stateTrade.store.unlockMargin(order.user, order.margin);
        }

        stateTrade.store.removeOrder(orderId);
        stateTrade.store.incrementBalance(order.user, order.fee);

        emit OrderCancelled(orderId, order.user);
    }

    function executeOrders() external {
        uint256[] memory orderIds = getExecutableOrderIds();
        for (uint256 i = 0; i < orderIds.length; i++) {
            uint256 orderId = orderIds[i];
            IStore.Order memory order = stateTrade.storeView.getOrder(orderId);
            if (order.size == 0 || order.price == 0) continue;
            IStore.Market memory market = stateTrade.storeView.getMarket(order.market);
            uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;
            _executeOrder(order, chainlinkPrice, msg.sender);
        }
    }



    function _executeOrder(IStore.Order memory order, uint256 price, address keeper) internal {
        // Check for existing position
        IStore.Position memory position = stateTrade.storeView.getPosition(order.user, order.market);

        bool doAdd = !order.isReduceOnly && (position.size == 0 || order.isLong == position.isLong);
        bool doReduce = position.size > 0 && order.isLong != position.isLong;

        if (doAdd) {
            _increasePosition(order, price, keeper);
        } else if (doReduce) {
            _decreasePosition(order, price, keeper);
        } else {
            _cancelOrder(order.orderId);
        }
    }

    // Position logic
    function _increasePosition(IStore.Order memory order, uint256 price, address keeper) internal {
        IStore.Position memory position = stateTrade.storeView.getPosition(order.user, order.market);

        stateTrade.store.incrementOI(order.market, order.size, order.isLong);

        _updateFundingTracker(order.market);

        uint256 averagePrice = (position.size * position.price + order.size * price) / (position.size + order.size);

        if (position.size == 0) {
            position.user = order.user;
            position.market = order.market;
            position.timestamp = uint64(block.timestamp);
            position.isLong = order.isLong;
            position.fundingTracker = stateTrade.storeView.getFundingTracker(order.market);
        }

        position.size += order.size;
        position.margin += order.margin;
        position.price = averagePrice;

        stateTrade.store.addOrUpdatePosition(position);

        if (order.orderId > 0) {
            stateTrade.store.removeOrder(order.orderId);
        }

        // Credit fees
        uint256 fee = order.fee;
        uint256 keeperFee = fee * stateTrade.storeView.keeperFeeShare() / BPS_DIVIDER;
        fee -= keeperFee;
        stateTrade.pool.creditFee(order.user, order.market, fee, false);
        stateTrade.store.incrementBalance(keeper, keeperFee);

        emit PositionIncreased(
            order.orderId,
            order.user,
            order.market,
            order.isLong,
            order.size,
            order.margin,
            price,
            position.margin,
            position.size,
            position.price,
            position.fundingTracker,
            fee,
            keeperFee
            );
    }

    function _decreasePosition(IStore.Order memory order, uint256 price, address keeper) internal {
        IStore.Position memory position = stateTrade.storeView.getPosition(order.user, order.market);
        IStore.Market memory market = stateTrade.storeView.getMarket(order.market);

        uint256 executedOrderSize = position.size > order.size ? order.size : position.size;
        uint256 remainingOrderSize = order.size - executedOrderSize;

        if (order.isReduceOnly) {
            // order.margin = 0
            // A fee (order.fee) corresponding to order.size was taken from balance on submit. Only fee corresponding to executedOrderSize should be charged, rest should be returned, if any
            stateTrade.store.incrementBalance(order.user, order.fee * remainingOrderSize / order.size);
        }

        // Funding update
        stateTrade.store.decrementOI(order.market, order.size, position.isLong);
        _updateFundingTracker(order.market);

        // P/L

        (int256 pnl, int256 fundingFee) =
            _getPnL(order.market, position.isLong, price, position.price, executedOrderSize, position.fundingTracker);

        uint256 marginToFree = executedOrderSize / market.maxLeverage;

        position.size -= executedOrderSize;
        position.margin -= marginToFree;
        position.fundingTracker = stateTrade.storeView.getFundingTracker(order.market);

        if (pnl < 0) {
            uint256 absPnl = uint256(-1 * pnl);
            // credit trader loss to pool
            stateTrade.pool.creditTraderLoss(order.user, order.market, absPnl);
        } else {
            stateTrade.pool.debitTraderProfit(order.user, order.market, uint256(pnl));
        }

        stateTrade.store.unlockMargin(order.user, marginToFree);

        if (position.size == 0) {
            stateTrade.store.removePosition(order.user, order.market);
        } else {
            stateTrade.store.addOrUpdatePosition(position);
        }

        stateTrade.store.removeOrder(order.orderId);

        // Open position in opposite direction if size remains
        if (!order.isReduceOnly && remainingOrderSize > 0) {
            IStore.Order memory nextOrder = IStore.Order({
                orderId: 0,
                user: order.user,
                market: order.market,
                margin: remainingOrderSize / market.maxLeverage,
                size: remainingOrderSize,
                price: 0,
                isLong: order.isLong,
                orderType: 0,
                fee: uint192(order.fee * remainingOrderSize / order.size),
                isReduceOnly: false,
                timestamp: uint64(block.timestamp)
            });

            _increasePosition(nextOrder, price, keeper);
        }

        // Credit fees
        uint256 fee = order.fee;
        uint256 keeperFee = fee * stateTrade.storeView.keeperFeeShare() / BPS_DIVIDER;
        fee -= keeperFee;
        stateTrade.pool.creditFee(order.user, order.market, fee, false);
        stateTrade.store.incrementBalance(keeper, keeperFee);

        emit PositionDecreased(
            order.orderId,
            order.user,
            order.market,
            order.isLong,
            executedOrderSize,
            marginToFree,
            price,
            position.margin,
            position.size,
            position.price,
            position.fundingTracker,
            fee,
            keeperFee,
            pnl,
            fundingFee
            );
    }

    function closePositionWithoutProfit(string memory _market) external {
        address user = msg.sender;

        IStore.Position memory position = stateTrade.storeView.getPosition(user, _market);
        require(position.size > 0, "!position");

        IStore.Market memory market = stateTrade.storeView.getMarket(_market);

        stateTrade.store.decrementOI(_market, position.size, position.isLong);

        _updateFundingTracker(_market);

        uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
        require(chainlinkPrice > 0, "!price");

        // P/L

        (int256 pnl,) =
            _getPnL(_market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker);

        // Only profitable positions can be closed this way
        require(pnl >= 0, "pnl < 0");

        stateTrade.store.unlockMargin(user, position.margin);
        stateTrade.store.removePosition(user, _market);

        // Credit fees
        uint256 fee = position.size * market.fee / BPS_DIVIDER;
        stateTrade.pool.creditFee(user, _market, fee, false);

        emit PositionDecreased(
            0,
            user,
            _market,
            !position.isLong,
            position.size,
            position.margin,
            chainlinkPrice,
            position.margin,
            position.size,
            position.price,
            position.fundingTracker,
            fee,
            0,
            0,
            0
            );
    }

    function liquidateUsers() external {
        address[] memory usersToLiquidate = getLiquidatableUsers();
        uint256 userLength = usersToLiquidate.length;
        uint256 liquidatorFees;

        for (uint256 i = 0; i < userLength; i++) {
            uint256 userFees;

            address user = usersToLiquidate[i];
            IStore.Position[] memory positions = stateTrade.storeView.getUserPositions(user);
            uint256 posLength = positions.length;

            for (uint256 j = 0; j < posLength; j++) {
                IStore.Position memory position = positions[j];
                IStore.Market memory market = stateTrade.storeView.getMarket(position.market);

                uint256 fee = position.size * market.fee / BPS_DIVIDER;
                uint256 liquidatorFee = fee * stateTrade.storeView.keeperFeeShare() / BPS_DIVIDER;
                fee -= liquidatorFee;
                liquidatorFees += liquidatorFee;
                userFees += fee + liquidatorFee;

                stateTrade.store.decrementOI(position.market, position.size, position.isLong);
                _updateFundingTracker(position.market);
                stateTrade.store.removePosition(user, position.market);

                uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);

                // Credit fees
                stateTrade.pool.creditFee(user, position.market, fee, true);

                emit PositionLiquidated(
                    user,
                    position.market,
                    position.isLong,
                    position.size,
                    position.margin,
                    chainlinkPrice,
                    fee,
                    liquidatorFee
                    );
            }

            // Credit full user balance minus fees
            stateTrade.pool.creditTraderLoss(user, "all", stateTrade.storeView.getBalance(user) - userFees);
            // set margin and user balance to zero
            stateTrade.store.unlockMargin(user, stateTrade.storeView.getLockedMargin(user));
            stateTrade.store.decrementBalance(user, stateTrade.storeView.getBalance(user));
        }

        // credit liquidator fees
        stateTrade.store.incrementBalance(msg.sender, liquidatorFees);
    }










    function _updateFundingTracker(string memory market) internal {
        uint256 lastUpdated = stateTrade.storeView.getFundingLastUpdated(market);
        uint256 _now = block.timestamp;

        if (lastUpdated == 0) {
            stateTrade.store.setFundingLastUpdated(market, _now);
            return;
        }

        if (lastUpdated + stateTrade.storeView.FUNDING_INTERVAL() > _now) return;

        int256 fundingIncrement = getAccruedFunding(market, 0); // in UNIT * bps

        if (fundingIncrement == 0) return;

        stateTrade.store.updateFundingTracker(market, fundingIncrement);
        stateTrade.store.setFundingLastUpdated(market, _now);

        emit FundingUpdated(market, stateTrade.storeView.getFundingTracker(market), fundingIncrement);
    }

}
