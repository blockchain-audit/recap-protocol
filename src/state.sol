
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

struct ChainLink {
    uint256 public constant UNIT = 10 ** 18;
    uint256 public constant GRACE_PERIOD_TIME = 3600;
}
struct Store{
        // constants
    uint256 public constant MAX_FEE = 500; // in bps = 5%
    uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

    // contracts
    address public currency;
    address public swapRouter;
    address public quoter;
    address public weth;


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
struct ContractAddress{

    address public trade;
    address public pool;
    address public clp;
    address public store;

}
struct RemainingData{
    //what is this address
    //find in store and pool  smart contracts
    address public gov;
    // find to store and pool smart contracts
    uint256 public constant BPS_DIVIDER = 10000;

}
struct Pool{
    address public treasury;
    IStore public store;
}
struct State {
    RemainingData remainingData;
    Store store;
    ChainLink chainlink;
    ContractAddress contractAddr;
    Pool pool;
}

abstract contract RecapStorage {
    State internal state;
}