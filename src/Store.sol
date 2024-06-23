// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// "openzeppelin-tokens=lib/openzeppelin-contracts/contracts/token",

import "openzeppelin-tokens/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "lib/v3-periphery/contracts/interfaces/IQuoter.sol";

import "./interfaces/IStore.sol";
import "./interfaces/ICLP.sol";

import {State} from "./Storage.sol";

contract Store is IStore {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    // constants
    uint256 public constant BPS_DIVIDER = 10000;
    uint256 public constant MAX_FEE = 500; // in bps = 5%
    uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

    // contracts

    // Variables

    // Funding

    // Modifiers

    modifier onlyContract() {
        require(msg.sender == State.contracts.trade || msg.sender == State.pool, "!contract");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == State.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        State.gov = _gov;
    }

    // Gov methods

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = State.gov;
        State.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _pool, address _currency, address _clp) external onlyGov {
        State.contracts.trade = _trade;
        State.pool = _pool;
        State.contracts.currency = _currency;
        State.contracts.clp = _clp;
    }

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external onlyGov {
        State.contracts.swapRouter = _swapRouter;
        State.contracts.quoter = _quoter;
        State.contracts.weth = _weth; // _weth = WMATIC on Polygon
    }

    function setPoolFeeShare(uint256 amount) external onlyGov {
        State.Variables.poolFeeShare = amount;
    }

    function setKeeperFeeShare(uint256 amount) external onlyGov {
        require(amount <= MAX_KEEPER_FEE_SHARE, "!max-keeper-fee-share");
        State.Variables.keeperFeeShare = amount;
    }

    function setPoolWithdrawalFee(uint256 amount) external onlyGov {
        require(amount <= MAX_POOL_WITHDRAWAL_FEE, "!max-pool-withdrawal-fee");
        State.Variables.poolWithdrawalFee = amount;
    }

    function setMinimumMarginLevel(uint256 amount) external onlyGov {
        State.Variables.minimumMarginLevel = amount;
    }

    function setBufferPayoutPeriod(uint256 amount) external onlyGov {
        State.Variables.bufferPayoutPeriod = amount;
    }

    function setMarket(string calldata market, Market calldata marketInfo) external onlyGov {
        require(marketInfo.fee <= MAX_FEE, "!max-fee");
        State.Mapping.markets[market] = marketInfo;
        for (uint256 i = 0; i < State.Mapping.marketList.length; i++) {
            if (keccak256(abi.encodePacked(State.Mapping.marketList[i])) == keccak256(abi.encodePacked(market))) return;
        }
        State.Mapping.marketList.push(market);
    }

    // Methods

    function transferIn(address user, uint256 amount) external onlyContract {
        IERC20(State.Contracts.currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(address user, uint256 amount) external onlyContract {
        IERC20(State.Contracts.currency).safeTransfer(user, amount);
    }

    // CLP methods
    function mintCLP(address user, uint256 amount) external onlyContract {
        ICLP(State.Contracts.clp).mint(user, amount);
    }

    function burnCLP(address user, uint256 amount) external onlyContract {
        ICLP(State.Contracts.clp).burn(user, amount);
    }

    function getCLPSupply() external view returns (uint256) {
        return IERC20(State.Contracts.clp).totalSupply();
    }

    // Uniswap methods
    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        onlyContract
        returns (uint256 amountOut)
    {
        require(address(State.Contracts.swapRouter) != address(0), "!swapRouter");

        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = State.Contracts.weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).safeApprove(address(State.Contracts.swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: State.Contracts.currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(State.Contracts.swapRouter).exactInputSingle{value: msg.value}(params);
    }

    // Function is not marked as view because it relies on calling non-view functions
    // Not gas efficient so shouldnt be called on-chain
    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut)
    {
        return IQuoter(State.Contracts.quoter).quoteExactInputSingle(tokenIn, State.Contracts.currency, poolFee, amountIn, 0);
    }

    // User balance
    function incrementBalance(address user, uint256 amount) external onlyContract {
        State.Mapping.balances[user] += amount;
    }

    function decrementBalance(address user, uint256 amount) external onlyContract {
        require(amount <= State.Mapping.balances[user], "!balance");
        State.Mapping.balances[user] -= amount;
    }

    function getBalance(address user) external view returns (uint256) {
        return State.Mapping.balances[user];
    }

    // Pool
    function incrementPoolBalance(uint256 amount) external onlyContract {
        State.Variables.poolBalance += amount;
    }

    function decrementPoolBalance(uint256 amount) external onlyContract {
        State.Variables.poolBalance -= amount;
    }

    function setPoolLastPaid(uint256 timestamp) external onlyContract {
        State.Variables.poolLastPaid = timestamp;
    }

    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(State.Contracts.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(State.Contracts.clp).balanceOf(user) * State.Variables.poolBalance / clpSupply;
    }

    // Buffer
    function incrementBufferBalance(uint256 amount) external onlyContract {
        State.Variables.bufferBalance += amount;
    }

    function decrementBufferBalance(uint256 amount) external onlyContract {
        State.Variables.bufferBalance -= amount;
    }

    // Margin
    function lockMargin(address user, uint256 amount) external onlyContract {
        State.Mapping.lockedMargins[user] += amount;
        State.Mapping.usersWithLockedMargin.add(user);
    }

    function unlockMargin(address user, uint256 amount) external onlyContract {
        if (amount > State.Mapping.lockedMargins[user]) {
            State.Mapping.lockedMargins[user] = 0;
        } else {
            State.Mapping.lockedMargins[user] -= amount;
        }
        if (State.Mapping.lockedMargins[user] == 0) {
            State.Mapping.usersWithLockedMargin.remove(user);
        }
    }

    function getLockedMargin(address user) external view returns (uint256) {
        return State.Mapping.lockedMargins[user];
    }

    function getUsersWithLockedMarginLength() external view returns (uint256) {
        return State.Mapping.usersWithLockedMargin.length();
    }

    function getUserWithLockedMargin(uint256 i) external view returns (address) {
        return State.Mapping.usersWithLockedMargin.at(i);
    }

    // Open interest
    function incrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            State.Mapping.OILong[market] += size;
            require(State.Mapping.markets[market].maxOI >= State.Mapping.OILong[market], "!max-oi");
        } else {
            State.Mapping.OIShort[market] += size;
            require(State.Mapping.markets[market].maxOI >= State.Mapping.OIShort[market], "!max-oi");
        }
    }

    function decrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            if (size > State.Mapping.OILong[market]) {
                State.Mapping.OILong[market] = 0;
            } else {
                State.Mapping.OILong[market] -= size;
            }
        } else {
            if (size > State.Mapping.OIShort[market]) {
                State.Mapping.OIShort[market] = 0;
            } else {
                State.Mapping.OIShort[market] -= size;
            }
        }
    }

    function getOILong(string calldata market) external view returns (uint256) {
        return State.Mapping.OILong[market];
    }

    function getOIShort(string calldata market) external view returns (uint256) {
        return State.Mapping.OIShort[market];
    }

    // Orders
    function addOrder(Order memory order) external onlyContract returns (uint256) {
        uint256 nextOrderId = State.Variables.orderId++;
        order.orderId = uint72(nextOrderId);
        State.Mapping.orders[nextOrderId] = order;
        State.Mapping.userOrderIds[order.user].add(nextOrderId);
        State.MappingorderIds.add(nextOrderId);
        return nextOrderId;
    }

    function updateOrder(Order calldata order) external onlyContract {
        State.Variables.orders[order.orderId] = order;
    }

    function removeOrder(uint256 _orderId) external onlyContract {
        Order memory order = State.Mapping.orders[_orderId];
        if (order.size == 0) return;
        State.Mapping.userOrderIds[order.user].remove(_orderId);
        State.Mapping.orderIds.remove(_orderId);
        delete State.Mapping.orders[_orderId];
    }

    function getOrder(uint256 id) external view returns (Order memory _order) {
        return State.Mapping.orders[id];
    }

    function getOrders() external view returns (Order[] memory _orders) {
        uint256 length = State.Mapping.orderIds.length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = State.Mapping.orders[State.Mapping.orderIds.at(i)];
        }
        return _orders;
    }

    function getUserOrders(address user) external view returns (Order[] memory _orders) {
        uint256 length = State.Mapping.userOrderIds[user].length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = State.Mapping.orders[State.Mapping.userOrderIds[user].at(i)];
        }
        return _orders;
    }

    // Positions
    function addOrUpdatePosition(Position calldata position) external onlyContract {
        bytes32 key = _getPositionKey(position.user, position.market);
        State.Mapping.positions[key] = position;
        State.Mapping.positionKeysForUser[position.user].add(key);
        State.Mapping.positionKeys.add(key);
    }

    function removePosition(address user, string calldata market) external onlyContract {
        bytes32 key = _getPositionKey(user, market);
        State.Mapping.positionKeysForUser[user].remove(key);
        State.Mapping.positionKeys.remove(key);
        delete State.Mapping.positions[key];
    }

    function getUserPositions(address user) external view returns (Position[] memory _positions) {
        uint256 length = State.Mapping.positionKeysForUser[user].length();
        _positions = new Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] = State.Mapping.positions[State.Mapping.positionKeysForUser[user].at(i)];
        }
        return _positions;
    }

    function getPosition(address user, string calldata market) public view returns (Position memory position) {
        bytes32 key = _getPositionKey(user, market);
        return State.Mapping.positions[key];
    }

    function _getPositionKey(address user, string calldata market) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, market));
    }

    // Markets
    function getMarket(string calldata market) external view returns (Market memory _market) {
        return State.Mapping.markets[market];
    }

    function getMarketList() external view returns (string[] memory) {
        return State.Funding.marketList;
    }

    // Funding
    function setFundingLastUpdated(string calldata market, uint256 timestamp) external onlyContract {
        State.Funding.fundingLastUpdated[market] = timestamp;
    }

    function updateFundingTracker(string calldata market, int256 fundingIncrement) external onlyContract {
        State.Funding.fundingTrackers[market] += fundingIncrement;
    }

    function getFundingLastUpdated(string calldata market) external view returns (uint256) {
        return State.Funding.fundingLastUpdated[market];
    }

    function getFundingFactor(string calldata market) external view returns (uint256) {
        return State.Mapping.markets[market].fundingFactor;
    }

    function getFundingTracker(string calldata market) external view returns (int256) {
        return State.Funding.fundingTrackers[market];
    }
}
