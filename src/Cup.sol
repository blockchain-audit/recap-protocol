// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";


import "../lib/v3-periphery/contracts/interfaces/IQuoter.sol";

import "./interfaces/IStore.sol";
import "./interfaces/ICLP.sol";
import "./CupStorage.sol";
contract Store is IStore,CapStorage {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

  

    // Modifiers

    modifier onlyContract() {
        require(msg.sender == state.poolContracts.trade || msg.sender == state.poolContracts.pool, "!contract");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == state.currencyContracts.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        state.currencyContracts.gov = _gov;
    }

    // Gov methods

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = state.currencyContracts.gov;
        state.currencyContracts.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _pool, address _currency, address _clp) external onlyGov {
       state.poolContracts.trade = _trade;
        state.poolContracts.pool = _pool;
        state.currencyContracts.currency = _currency;
        state.currencyContracts.clp = _clp;
    }

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external onlyGov {
        state.swapContracts.swapRouter = _swapRouter;
        state.swapContracts.quoter = _quoter;
        state.swapContracts.weth = _weth; // _weth = WMATIC on Polygon
    }

    function setPoolFeeShare(uint256 amount) external onlyGov {
        state.fee.poolFeeShare = amount;
    }

    function setKeeperFeeShare(uint256 amount) external onlyGov {
        require(amount <=CapStorage.MAX_KEEPER_FEE_SHARE , "!max-keeper-fee-share");
        state.fee.keeperFeeShare = amount;
    }

    function setPoolWithdrawalFee(uint256 amount) external onlyGov {
        require(amount <= CapStorage.MAX_KEEPER_FEE_SHARE, "!max-pool-withdrawal-fee");
        state.fee.poolWithdrawalFee = amount;
    }

    function setMinimumMarginLevel(uint256 amount) external onlyGov {
        state.fee.minimumMarginLevel = amount;
    }

    function setBufferPayoutPeriod(uint256 amount) external onlyGov {
        state.buffer.bufferPayoutPeriod = amount;
    }

    function setMarket(string calldata market, Market calldata marketInfo) external onlyGov {
        require(marketInfo.fee <= CapStorage.getMaxFee(), "!max-fee");
        state.marketData.markets[market] = marketInfo;
        for (uint256 i = 0; i < state.marketData.marketList.length; i++) {
            if (keccak256(abi.encodePacked(state.marketData.marketList[i])) == keccak256(abi.encodePacked(market))) return;
        }
        state.marketData.marketList.push(market);
    }

    // Methods

    function transferIn(address user, uint256 amount) external onlyContract {
        IERC20(state.currencyContracts.currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(address user, uint256 amount) external onlyContract {
        IERC20(state.currencyContracts.currency).safeTransfer(user, amount);
    }

    // CLP methods
    function mintCLP(address user, uint256 amount) external onlyContract {
        ICLP(state.currencyContracts.clp).mint(user, amount);
    }

    function burnCLP(address user, uint256 amount) external onlyContract {
        ICLP(state.currencyContracts.clp).burn(user, amount);
    }

    function getCLPSupply() external view returns (uint256) {
        return IERC20(state.currencyContracts.clp).totalSupply();
    }

    // Uniswap methods
    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        onlyContract
        returns (uint256 amountOut)
    {
        require(address(state.swapContracts.swapRouter) != address(0), "!swapRouter");

        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = state.swapContracts.weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).approve(address(state.swapContracts.swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: CurrencyContracts.currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(state.swapContracts.swapRouter).exactInputSingle{value: msg.value}(params);
    }

    // Function is not marked as view because it relies on calling non-view functions
    // Not gas efficient so shouldnt be called on-chain
    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut)
    {
        return IQuoter(state.swapContracts.quoter).quoteExactInputSingle(tokenIn, state.currencyContracts.currency, poolFee, amountIn, 0);
    }

    // User balance
    function incrementBalance(address user, uint256 amount) external onlyContract {
        state.userData.balances[user] += amount;
    }

    function decrementBalance(address user, uint256 amount) external onlyContract {
        require(amount <= state.userData.balances[user], "!balance");
        state.userData.balances[user] -= amount;
    }

    function getBalance(address user) external view returns (uint256) {
        return state.userData.balances[user];
    }

    // Pool
    function incrementPoolBalance(uint256 amount) external onlyContract {
        state.poolBalance += amount;
    }

    function decrementPoolBalance(uint256 amount) external onlyContract {
        state.poolBalance.poolBalance -= amount;
    }

    function setPoolLastPaid(uint256 timestamp) external onlyContract {
          state.poolBalance.poolLastPaid = timestamp;
    }

    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(CurrencyContracts.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(  state.currencyContracts.clp).balanceOf(user) * state.poolBalance / clpSupply;
    }

    // Buffer
    function incrementBufferBalance(uint256 amount) external onlyContract {
          state.poolBalance.bufferBalance += amount;
    }

    function decrementBufferBalance(uint256 amount) external onlyContract {
          state.poolBalance.bufferBalance -= amount;
    }

    // Margin
    function lockMargin(address user, uint256 amount) external onlyContract {
          state.userData.lockedMargins[user] += amount;
          state.userData.usersWithLockedMargin.add(user);
    }

    function unlockMargin(address user, uint256 amount) external onlyContract {
        if (amount >   state.userData.lockedMargins[user]) {
              state.userData.lockedMargins[user] = 0;
        } else {
              state.userData.lockedMargins[user] -= amount;
        }
        if (  state.userData.lockedMargins[user] == 0) {
              state.userData.usersWithLockedMargin.remove(user);
        }
    }

    function getLockedMargin(address user) external view returns (uint256) {
        return state.userData.lockedMargins[user];
    }

    function getUsersWithLockedMarginLength() external view returns (uint256) {
        return   state.userData.usersWithLockedMargin.length();
    }

    function getUserWithLockedMargin(uint256 i) external view returns (address) {
        return   state.userData.usersWithLockedMargin.at(i);
    }

    // Open interest
    function incrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
              state.MarketData.OILong[market] += size;
            require(  state.marketData.markets[market].maxOI >=   state.marketData.OILong[market], "!max-oi");
        } else {
              state.MarketData.OIShort[market] += size;
            require(  state.marketData.markets[market].maxOI >=   state.marketData.OIShort[market], "!max-oi");
        }
    }

    function decrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            if (size >   state.marketData.OILong[market]) {
                  state.marketData.OILong[market] = 0;
            } else {
                  state.marketData.OILong[market] -= size;
            }
        } else {
            if (size > state.marketData.OIShort[market]) {
                  state.marketData.OIShort[market] = 0;
            } else {
                  state.marketData.OIShort[market] -= size;
            }
        }
    }

    function getOILong(string calldata market) external view returns (uint256) {
        return   state.marketData.OILong[market];
    }

    function getOIShort(string calldata market) external view returns (uint256) {
        return   state.marketData.OIShort[market];
    }

    // Orders
    function addOrder(Order memory order) external onlyContract returns (uint256) {
        uint256 nextOrderId = ++order.orderId;
          state.order.orderId = uint72(nextOrderId);
          state.OrderData.orders[nextOrderId] = order;
          state.OrderData.userOrderIds[order.user].add(nextOrderId);
          state.OrderData.orderIds.add(nextOrderId);
        return nextOrderId;
    }

    function updateOrder(Order calldata order) external onlyContract {
          state.orderData.orders[order.orderId] = order;
    }

    function removeOrder(uint256 _orderId) external onlyContract {
        Order memory order = OrderData.orders[_orderId];
        if (  state.order.size == 0) return;
          state.orderData.userOrderIds[  state.order.user].remove(_orderId);
          state.orderData.orderIds.remove(_orderId);
        delete   state.orderData.orders[_orderId];
    }

    function getOrder(uint256 id) external view returns (Order memory _order) {
        return   state.orderData.orders[id];
    }

    function getOrders() external view returns (Order[] memory _orders) {
        uint256 length =   state.orderData.orderIds.length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] =   state.orderData.orders[  state.orderData.orderIds.at(i)];
        }
        return _orders;
    }

    function getUserOrders(address user) external view returns (Order[] memory _orders) {
        uint256 length =   state.orderData.userOrderIds[user].length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] =   state.orderData.orders[  state.orderData.userOrderIds[user].at(i)];
        }
        return _orders;
    }

    // Positions
    function addOrUpdatePosition(Position calldata position) external onlyContract {
        bytes32 key = _getPositionKey(position.user, position.market);
          state.positionData.positions[key] = position;
          state.positionData.positionKeysForUser[position.user].add(key);
          state.positionData.positionKeys.add(key);
    }

    function removePosition(address user, string calldata market) external onlyContract {
        bytes32 key = _getPositionKey(user, market);
          state.positionData.positionKeysForUser[user].remove(key);
          state.positionData.positionKeys.remove(key);
        delete   state.positionData.positions[key];
    }

    function getUserPositions(address user) external view returns (Position[] memory _positions) {
        uint256 length =   state.positionData.positionKeysForUser[user].length();
        _positions = new Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] =   state.positionData.positions[  state.positionData.positionKeysForUser[user].at(i)];
        }
        return _positions;
    }

    function getPosition(address user, string calldata market) public view returns (Position memory position) {
        bytes32 key = _getPositionKey(user, market);
        return   state.positionData.positions[key];
    }

    function _getPositionKey(address user, string calldata market) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, market));
    }

    // Markets
    function getMarket(string calldata market) external view returns (Market memory _market) {
        return   state.marketData.markets[market];
    }

    function getMarketList() external view returns (string[] memory) {
        return   state.marketData.marketList;
    }

    // Funding
    function setFundingLastUpdated(string calldata market, uint256 timestamp) external onlyContract {
          state.funding.fundingLastUpdated[market] = timestamp;
    }

    function updateFundingTracker(string calldata market, int256 fundingIncrement) external onlyContract {
          state.funding.fundingTrackers[market] += fundingIncrement;
    }

    function getFundingLastUpdated(string calldata market) external view returns (uint256) {
        return   state.funding.fundingLastUpdated[market];
    }

    function getFundingFactor(string calldata market) external view returns (uint256) {
        return   state.marketData.markets[market].fundingFactor;
    }

    function getFundingTracker(string calldata market) external view returns (int256) {
        return   state.funding.fundingTrackers[market];
    }
}
