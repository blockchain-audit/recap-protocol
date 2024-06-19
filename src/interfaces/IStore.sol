// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface IStore {
    // Events
    event GovernanceUpdated(address indexed oldGov, address indexed newGov);

    // Structs
    struct Market {
        string symbol;
        address feed;
        uint16 minSettlementTime; // overflows at ~18hrs
        uint16 maxLeverage; // overflows at 65535
        uint32 fee; // in bps, overflows at 4.3 billion
        uint32 fundingFactor; // Yearly funding rate if OI is completely skewed to one side. In bps.
        uint256 maxOI;
        uint256 minSize;
    }

    struct Order {
        bool isLong;
        bool isReduceOnly;
        uint8 orderType; // 0 = market, 1 = limit, 2 = stop
        uint72 orderId; // overflows at 4.7 * 10**21
        address user;
        string market;
        uint64 timestamp;
        uint192 fee;
        uint256 price;
        uint256 margin;
        uint256 size;
    }

    struct Position {
        bool isLong;
        uint64 timestamp;
        address user;
        string market;
        int256 fundingTracker;
        uint256 price;
        uint256 margin;
        uint256 size;
    }

    function BPS_DIVIDER() external view returns (uint256);

    function FUNDING_INTERVAL() external view returns (uint256);

    function MAX_FEE() external view returns (uint256);

    function MAX_KEEPER_FEE_SHARE() external view returns (uint256);

    function MAX_POOL_WITHDRAWAL_FEE() external view returns (uint256);

    function addOrUpdatePosition(Position memory position) external;

    function addOrder(Order memory order) external returns (uint256);

    function bufferBalance() external view returns (uint256);

    function bufferPayoutPeriod() external view returns (uint256);

    function burnCLP(address user, uint256 amount) external;

    function decrementBalance(address user, uint256 amount) external;

    function decrementBufferBalance(uint256 amount) external;

    function decrementOI(string memory market, uint256 size, bool isLong) external;

    function decrementPoolBalance(uint256 amount) external;

    function getBalance(address user) external view returns (uint256);

    function getCLPSupply() external view returns (uint256);

    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut);

    function getFundingFactor(string memory market) external view returns (uint256);

    function getFundingLastUpdated(string memory market) external view returns (uint256);

    function getFundingTracker(string memory market) external view returns (int256);

    function getLockedMargin(address user) external view returns (uint256);

    function getMarket(string memory market) external view returns (Market memory _market);

    function getMarketList() external view returns (string[] memory);

    function getOILong(string memory market) external view returns (uint256);

    function getOIShort(string memory market) external view returns (uint256);

    function getOrder(uint256 id) external view returns (Order memory _order);

    function getOrders() external view returns (Order[] memory _orders);

    function getPosition(address user, string memory market) external view returns (Position memory position);

    function getUserOrders(address user) external view returns (Order[] memory _orders);

    function getUserPoolBalance(address user) external view returns (uint256);

    function getUserPositions(address user) external view returns (Position[] memory _positions);

    function getUserWithLockedMargin(uint256 i) external view returns (address);

    function getUsersWithLockedMarginLength() external view returns (uint256);

    function incrementBalance(address user, uint256 amount) external;

    function incrementBufferBalance(uint256 amount) external;

    function incrementOI(string memory market, uint256 size, bool isLong) external;

    function incrementPoolBalance(uint256 amount) external;

    function keeperFeeShare() external view returns (uint256);

    function link(address _trade, address _pool, address _currency, address _clp) external;

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external;

    function lockMargin(address user, uint256 amount) external;

    function marketList(uint256) external view returns (string memory);

    function minimumMarginLevel() external view returns (uint256);

    function mintCLP(address user, uint256 amount) external;

    function poolBalance() external view returns (uint256);

    function poolFeeShare() external view returns (uint256);

    function poolLastPaid() external view returns (uint256);

    function poolWithdrawalFee() external view returns (uint256);

    function removeOrder(uint256 _orderId) external;

    function removePosition(address user, string memory market) external;

    function setBufferPayoutPeriod(uint256 amount) external;

    function setFundingLastUpdated(string memory market, uint256 timestamp) external;

    function setKeeperFeeShare(uint256 amount) external;

    function setMarket(string memory market, Market memory marketInfo) external;

    function setMinimumMarginLevel(uint256 amount) external;

    function setPoolFeeShare(uint256 amount) external;

    function setPoolLastPaid(uint256 timestamp) external;

    function setPoolWithdrawalFee(uint256 amount) external;

    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        returns (uint256 amountOut);

    function transferIn(address user, uint256 amount) external;

    function transferOut(address user, uint256 amount) external;

    function unlockMargin(address user, uint256 amount) external;

    function updateFundingTracker(string memory market, int256 fundingIncrement) external;

    function updateGov(address _gov) external;

    function updateOrder(Order memory order) external;


    //storage
    struct stateStore{
         // constants
    uint256 public constant BPS_DIVIDER = 10000;
    uint256 public constant MAX_FEE = 500; // in bps = 5%
    uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

    // contracts
    address public gov;
    address public currency;
    address public clp;

    address public swapRouter;
    address public quoter;
    address public weth;

    address public trade;
    address public pool;

    // Variables
    uint256 public poolFeeShare = 5000; // in bps
    uint256 public keeperFeeShare = 1000; // in bps
    uint256 public poolWithdrawalFee = 10; // in bps
    uint256 public minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated

    uint256 public bufferBalance;
    uint256 public poolBalance;
    uint256 public poolLastPaid;

    uint256 public bufferPayoutPeriod = 7 days;

    uint256 internal orderId;

    mapping(uint256 => Order) private orders;
    mapping(address => EnumerableSet.UintSet) private userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet private orderIds; // [order ids..]

    string[] public marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => Market) private markets;

    mapping(bytes32 => Position) private positions; // key = user,market
    EnumerableSet.Bytes32Set private positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) private positionKeysForUser; // user => [position keys..]

    mapping(string => uint256) private OILong;
    mapping(string => uint256) private OIShort;

    mapping(address => uint256) private balances; // user => amount
    mapping(address => uint256) private lockedMargins; // user => amount
    EnumerableSet.AddressSet private usersWithLockedMargin; // [users...]

    // Funding
    mapping(string => int256) private fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256) private fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.

    }
}
