// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./StorageTrade.sol";

contract ViewFuncTrade is StorageTrade{

    uint256 constant BPS_DIVIDER = 10000;
    uint256 constant UNIT = 10 ** 18;


    // StorageTrade.StateTrade public stateTrade = StorageTrade.stateTrade;

        function getExecutableOrderIds() public view returns (uint256[] memory orderIdsToExecute) {
        IStore.Order[] memory orders = stateTrade.storeView.getOrders();
        uint256[] memory _orderIds = new uint256[](orders.length);
        uint256 j;
        for (uint256 i = 0; i < orders.length; i++) {
            IStore.Order memory order = orders[i];
            IStore.Market memory market = stateTrade.storeView.getMarket(order.market);

            uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;

            // Can this order be executed?
            if (
                order.orderType == 0 || order.orderType == 1 && order.isLong && chainlinkPrice <= order.price
                    || order.orderType == 1 && !order.isLong && chainlinkPrice >= order.price
                    || order.orderType == 2 && order.isLong && chainlinkPrice >= order.price
                    || order.orderType == 2 && !order.isLong && chainlinkPrice <= order.price
            ) {
                // Check settlement time has passed, or chainlinkPrice is different for market order
                if (
                    order.orderType == 0 && chainlinkPrice != order.price
                        || block.timestamp - order.timestamp > market.minSettlementTime
                ) {
                    _orderIds[j] = order.orderId;
                    ++j;
                }
            }
        }

        // Return trimmed result containing only executable order ids
        orderIdsToExecute = new uint256[](j);
        for (uint256 i = 0; i < j; i++) {
            orderIdsToExecute[i] = _orderIds[i];
        }

        return orderIdsToExecute;
    }


        function getLiquidatableUsers() public view returns (address[] memory usersToLiquidate) {
        uint256 length = stateTrade.storeView.getUsersWithLockedMarginLength();
        address[] memory _users = new address[](length);
        uint256 j;
        for (uint256 i = 0; i < length; i++) {
            address user = stateTrade.storeView.getUserWithLockedMargin(i);
            int256 equity = int256(stateTrade.storeView.getBalance(user)) + getUpl(user);
            uint256 lockedMargin = stateTrade.storeView.getLockedMargin(user);
            uint256 marginLevel;
            if (equity <= 0) {
                marginLevel = 0;
            } else {
                marginLevel = BPS_DIVIDER * uint256(equity) / lockedMargin;
            }
            if (marginLevel < stateTrade.storeView.minimumMarginLevel()) {
                _users[j] = user;
                ++j;
            }
        }
        // Return trimmed result containing only users to be liquidated
        usersToLiquidate = new address[](j);
        for (uint256 i = 0; i < j; i++) {
            usersToLiquidate[i] = _users[i];
        }
        return usersToLiquidate;
    }


        function getUserPositionsWithUpls(address user)
        external
        view
        returns (IStore.Position[] memory _positions, int256[] memory _upls)
    {
        _positions = stateTrade.storeView.getUserPositions(user);
        uint256 length = _positions.length;
        _upls = new int256[](length);
        for (uint256 i = 0; i < length; i++) {
            IStore.Position memory position = _positions[i];

            IStore.Market memory market = stateTrade.storeView.getMarket(position.market);

            uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;

            (int256 pnl,) = _getPnL(
                position.market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker
            );

            _upls[i] = pnl;
        }

        return (_positions, _upls);
    }


        function _getPnL(
        string memory market,
        bool isLong,
        uint256 price,
        uint256 positionPrice,
        uint256 size,
        int256 fundingTracker
    ) internal view returns (int256 pnl, int256 fundingFee) {
        if (price == 0 || positionPrice == 0 || size == 0) return (0, 0);

        if (isLong) {
            pnl = int256(size) * (int256(price) - int256(positionPrice)) / int256(positionPrice);
        } else {
            pnl = int256(size) * (int256(positionPrice) - int256(price)) / int256(positionPrice);
        }

        int256 currentFundingTracker = stateTrade.storeView.getFundingTracker(market);
        fundingFee = int256(size) * (currentFundingTracker - fundingTracker) / (int256(BPS_DIVIDER) * int256(UNIT)); // funding tracker is in UNIT * bps

        if (isLong) {
            pnl -= fundingFee; // positive = longs pay, negative = longs receive
        } else {
            pnl += fundingFee; // positive = shorts receive, negative = shorts pay
        }

        return (pnl, fundingFee);
    }

        function getUpl(address user) public view returns (int256 upl) {
        IStore.Position[] memory positions = stateTrade.storeView.getUserPositions(user);
        for (uint256 j = 0; j < positions.length; j++) {
            IStore.Position memory position = positions[j];
            IStore.Market memory market = stateTrade.storeView.getMarket(position.market);

            uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;

            (int256 pnl,) = _getPnL(
                position.market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker
            );

            upl += pnl;
        }

        return upl;
    }

        // Funding
    function getAccruedFunding(string memory market, uint256 intervals) public view returns (int256) {
        if (intervals == 0) {
            intervals = (block.timestamp - stateTrade.storeView.getFundingLastUpdated(market)) / stateTrade.storeView.FUNDING_INTERVAL();
        }

        if (intervals == 0) return 0;

        uint256 OILong = stateTrade.storeView.getOILong(market);
        uint256 OIShort = stateTrade.storeView.getOIShort(market);

        if (OIShort == 0 && OILong == 0) return 0;

        uint256 OIDiff = OIShort > OILong ? OIShort - OILong : OILong - OIShort;
        uint256 yearlyFundingFactor = stateTrade.storeView.getFundingFactor(market); // in bps
        // intervals = hours since FUNDING_INTERVAL = 1 hour
        uint256 accruedFunding = UNIT * yearlyFundingFactor * OIDiff * intervals / (24 * 365 * (OILong + OIShort)); // in UNIT * bps

        if (OILong > OIShort) {
            // Longs pay shorts. Increase funding tracker.
            return int256(accruedFunding);
        } else {
            // Shorts pay longs. Decrease funding tracker.
            return -1 * int256(accruedFunding);
        }
    }

        function getMarketsWithPrices() external view returns (IStore.Market[] memory _markets, uint256[] memory _prices) {
        string[] memory marketList = stateTrade.storeView.getMarketList();
        uint256 length = marketList.length;
        _markets = new IStore.Market[](length);
        _prices = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            IStore.Market memory market = stateTrade.storeView.getMarket(marketList[i]);
            uint256 chainlinkPrice = stateTrade.chainlink.getPrice(market.feed);
            _markets[i] = market;
            _prices[i] = chainlinkPrice;
        }

        return (_markets, _prices);
    }

}