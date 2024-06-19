// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";

import "./interfaces/IStore.sol";
import "./interfaces/ICLP.sol";

contract Store is IStore {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    
    stateStore stateStore;

    // // constants
    // uint256 public constant BPS_DIVIDER = 10000;
    // uint256 public constant MAX_FEE = 500; // in bps = 5%
    // uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    // uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    // uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

    // // contracts
    // address public gov;
    // address public currency;
    // address public clp;

    // address public swapRouter;
    // address public quoter;
    // address public weth;

    // address public trade;
    // address public pool;

    // // Variables
    // uint256 public poolFeeShare = 5000; // in bps
    // uint256 public keeperFeeShare = 1000; // in bps
    // uint256 public poolWithdrawalFee = 10; // in bps
    // uint256 public minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated

    // uint256 public bufferBalance;
    // uint256 public poolBalance;
    // uint256 public poolLastPaid;

    // uint256 public bufferPayoutPeriod = 7 days;

    // uint256 internal orderId;

    // mapping(uint256 => Order) private orders;
    // mapping(address => EnumerableSet.UintSet) private userOrderIds; // user => [order ids..]
    // EnumerableSet.UintSet private orderIds; // [order ids..]

    // string[] public marketList; // "ETH-USD", "BTC-USD", etc
    // mapping(string => Market) private markets;

    // mapping(bytes32 => Position) private positions; // key = user,market
    // EnumerableSet.Bytes32Set private positionKeys; // [position keys..]
    // mapping(address => EnumerableSet.Bytes32Set) private positionKeysForUser; // user => [position keys..]

    // mapping(string => uint256) private OILong;
    // mapping(string => uint256) private OIShort;

    // mapping(address => uint256) private balances; // user => amount
    // mapping(address => uint256) private lockedMargins; // user => amount
    // EnumerableSet.AddressSet private usersWithLockedMargin; // [users...]

    // // Funding
    // mapping(string => int256) private fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    // mapping(string => uint256) private fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.

    // Modifiers

    modifier onlyContract() {
        require(msg.sender == stateStore.trade || msg.sender == stateStore.pool, "!contract");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == stateStore.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        stateStore.gov = _gov;
    }

    // Gov methods

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = gov;
        stateStore.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _pool, address _currency, address _clp) external onlyGov {
        stateStore.trade = _trade;
        stateStore.pool = _pool;
        stateStore.currency = _currency;
        stateStore.clp = _clp;
    }

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external onlyGov {
        stateStore.swapRouter = _swapRouter;
        stateStore.quoter = _quoter;
        stateStore.weth = _weth; // _weth = WMATIC on Polygon
    }

    function setPoolFeeShare(uint256 amount) external onlyGov {
        stateStore.poolFeeShare = amount;
    }

    function setKeeperFeeShare(uint256 amount) external onlyGov {
        require(amount <= MAX_KEEPER_FEE_SHARE, "!max-keeper-fee-share");
        stateStore.keeperFeeShare = amount;
    }

    function setPoolWithdrawalFee(uint256 amount) external onlyGov {
        require(amount <= MAX_POOL_WITHDRAWAL_FEE, "!max-pool-withdrawal-fee");
        stateStore.poolWithdrawalFee = amount;
    }

    function setMinimumMarginLevel(uint256 amount) external onlyGov {
        stateStore.minimumMarginLevel = amount;
    }

    function setBufferPayoutPeriod(uint256 amount) external onlyGov {
        stateStore.bufferPayoutPeriod = amount;
    }

    function setMarket(string calldata market, Market calldata marketInfo) external onlyGov {
        require(marketInfo.fee <= MAX_FEE, "!max-fee");
        stateStore.markets[market] = marketInfo;
        for (uint256 i = 0; i < stateStore.marketList.length; i++) {
            if (keccak256(abi.encodePacked(stateStore.marketList[i])) == keccak256(abi.encodePacked(market))) return;
        }
        stateStore.marketList.push(market);
    }

    // Methods

    function transferIn(address user, uint256 amount) external onlyContract {
        IERC20(stateStore.currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(address user, uint256 amount) external onlyContract {
        IERC20(stateStore.currency).safeTransfer(user, amount);
    }

    // CLP methods
    function mintCLP(address user, uint256 amount) external onlyContract {
        ICLP(stateStore.clp).mint(user, amount);
    }

    function burnCLP(address user, uint256 amount) external onlyContract {
        ICLP(stateStore.clp).burn(user, amount);
    }

    function getCLPSupply() external view returns (uint256) {
        return IERC20(stateStore.clp).totalSupply();
    }

    // Uniswap methods
    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        onlyContract
        returns (uint256 amountOut)
    {
        require(address(stateStore.swapRouter) != address(0), "!swapRouter");

        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).safeApprove(address(stateStore.swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(stateStore.swapRouter).exactInputSingle{value: msg.value}(params);
    }

    // Function is not marked as view because it relies on calling non-view functions
    // Not gas efficient so shouldnt be called on-chain
    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut)
    {
        return IQuoter(stateStore.quoter).quoteExactInputSingle(tokenIn, stateStore.currency, poolFee, amountIn, 0);
    }

    // User balance
    function incrementBalance(address user, uint256 amount) external onlyContract {
        stateStore.balances[user] += amount;
    }

    function decrementBalance(address user, uint256 amount) external onlyContract {
        require(amount <= balances[user], "!balance");
        stateStore.balances[user] -= amount;
    }

    function getBalance(address user) external view returns (uint256) {
        return stateStore.balances[user];
    }

    // Pool
    function incrementPoolBalance(uint256 amount) external onlyContract {
        stateStore.poolBalance += amount;
    }

    function decrementPoolBalance(uint256 amount) external onlyContract {
        stateStore.poolBalance -= amount;
    }

    function setPoolLastPaid(uint256 timestamp) external onlyContract {
        stateStore.poolLastPaid = timestamp;
    }

    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(stateStore.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(stateStore.clp).balanceOf(user) * stateStore.poolBalance / clpSupply;
    }

    // Buffer
    function incrementBufferBalance(uint256 amount) external onlyContract {
        stateStore.bufferBalance += amount;
    }

    function decrementBufferBalance(uint256 amount) external onlyContract {
        stateStore.bufferBalance -= amount;
    }

    // Margin
    function lockMargin(address user, uint256 amount) external onlyContract {
        stateStore.lockedMargins[user] += amount;
        stateStore.usersWithLockedMargin.add(user);
    }

    function unlockMargin(address user, uint256 amount) external onlyContract {
        if (amount > stateStore.lockedMargins[user]) {
            stateStore.lockedMargins[user] = 0;
        } else {
            stateStore.lockedMargins[user] -= amount;
        }
        if (stateStore.lockedMargins[user] == 0) {
            stateStore.usersWithLockedMargin.remove(user);
        }
    }

    function getLockedMargin(address user) external view returns (uint256) {
        return stateStore.lockedMargins[user];
    }

    function getUsersWithLockedMarginLength() external view returns (uint256) {
        return stateStore.usersWithLockedMargin.length();
    }

    function getUserWithLockedMargin(uint256 i) external view returns (address) {
        return stateStore.usersWithLockedMargin.at(i);
    }

    // Open interest
    function incrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            stateStore.OILong[market] += size;
            require(stateStore.markets[market].maxOI >= stateStore.OILong[market], "!max-oi");
        } else {
            stateStore.OIShort[market] += size;
            require(stateStore.markets[market].maxOI >= stateStore.OIShort[market], "!max-oi");
        }
    }

    function decrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            if (size > stateStore.OILong[market]) {
                stateStore.OILong[market] = 0;
            } else {
                stateStore.OILong[market] -= size;
            }
        } else {
            if (size > stateStore.OIShort[market]) {
                stateStore.OIShort[market] = 0;
            } else {
                stateStore.OIShort[market] -= size;
            }
        }
    }

    function getOILong(string calldata market) external view returns (uint256) {
        return stateStore.OILong[market];
    }

    function getOIShort(string calldata market) external view returns (uint256) {
        return stateStore.OIShort[market];
    }

    // Orders
    function addOrder(Order memory order) external onlyContract returns (uint256) {
        uint256 nextOrderId = ++stateStore.orderId;
        order.orderId = uint72(nextOrderId);
        stateStore.orders[nextOrderId] = order;
        stateStore.userOrderIds[order.user].add(nextOrderId);
        stateStore.orderIds.add(nextOrderId);
        return nextOrderId;
    }

    function updateOrder(Order calldata order) external onlyContract {
        stateStore.orders[order.orderId] = order;
    }

    function removeOrder(uint256 _orderId) external onlyContract {
        Order memory order = stateStore.orders[_orderId];
        if (stateStore.order.size == 0) return;
        stateStore.userOrderIds[stateStore.order.user].remove(_orderId);
        stateStore.orderIds.remove(_orderId);
        delete stateStore.orders[_orderId];
    }

    function getOrder(uint256 id) external view returns (Order memory _order) {
        return stateStore.orders[id];
    }

    function getOrders() external view returns (Order[] memory _orders) {
        uint256 length = stateStore.orderIds.length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = stateStore.orders[stateStore.orderIds.at(i)];
        }
        return _orders;
    }

    function getUserOrders(address user) external view returns (Order[] memory _orders) {
        uint256 length = stateStore.userOrderIds[user].length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = stateStore.orders[userOrderIds[user].at(i)];
        }
        return _orders;
    }

    // Positions
    function addOrUpdatePosition(Position calldata position) external onlyContract {
        bytes32 key = _getPositionKey(position.user, position.market);
        stateStore.positions[key] = position;
        stateStore.positionKeysForUser[position.user].add(key);
        stateStore.positionKeys.add(key);
    }

    function removePosition(address user, string calldata market) external onlyContract {
        bytes32 key = _getPositionKey(user, market);
        stateStore.positionKeysForUser[user].remove(key);
        stateStore.positionKeys.remove(key);
        delete stateStore.positions[key];
    }

    function getUserPositions(address user) external view returns (Position[] memory _positions) {
        uint256 length = stateStore.positionKeysForUser[user].length();
        _positions = new Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] = stateStore.positions[stateStore.positionKeysForUser[user].at(i)];
        }
        return _positions;
    }

    function getPosition(address user, string calldata market) public view returns (Position memory position) {
        bytes32 key = _getPositionKey(user, market);
        return stateStore.positions[key];
    }

    function _getPositionKey(address user, string calldata market) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, market));
    }

    // Markets
    function getMarket(string calldata market) external view returns (Market memory _market) {
        return stateStore.markets[market];
    }

    function getMarketList() external view returns (string[] memory) {
        return stateStore.marketList;
    }

    // Funding
    function setFundingLastUpdated(string calldata market, uint256 timestamp) external onlyContract {
        stateStore.fundingLastUpdated[market] = timestamp;
    }

    function updateFundingTracker(string calldata market, int256 fundingIncrement) external onlyContract {
        stateStore.fundingTrackers[market] += fundingIncrement;
    }

    function getFundingLastUpdated(string calldata market) external view returns (uint256) {
        return stateStore.fundingLastUpdated[market];
    }

    function getFundingFactor(string calldata market) external view returns (uint256) {
        return stateStore.markets[market].fundingFactor;
    }

    function getFundingTracker(string calldata market) external view returns (int256) {
        return stateStore.fundingTrackers[market];
    }
}
