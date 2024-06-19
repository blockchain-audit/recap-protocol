pragma solidity ^0.8.24;

import "./interfaces/IChainlink.sol";
import "./interfaces/IStore.sol";
import "./interfaces/IPool.sol";
import "./interfaces/ITrade.sol";
import "./interfaces/ICLP.sol";

struct Pool {
    // uint public constant BPS_DIVIDER = 10000;
    // address public gov;
    address trade;
    address treasury;
    // IStore public store;
}
struct Trade {
    uint constant UNIT = 10 ** 18;
    IChainlink chainlink;
    IPool pool;
}
struct StoreConstants {
    uint constant MAX_FEE = 500; // in bps = 5%
    uint constant MAX_KEEPER_FEE_SHARE = 2000; // in bps =  20%
    uint constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint constant FUNDING_INTERNAL = 1 hours; // In seconds
}
struct StoreContracts {
    address currency;
    address clp;
    address swapRouter;
    address qouter;
    address weth;
    address trade;
    address pool;
}
struct StoreVariables {
    uint256 poolFeeShare = 5000; // in bps
    uint256 keeperFeeShare = 1000; // in bps
    uint256 poolWithdrawalFee = 10; // in bps
    uint256 minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated

    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;

    uint256 bufferPayoutPeriod = 7 days;

    uint256 internal orderId;

    mapping(uint256 => Order) private orders;
    mapping(address => EnumerableSet.UintSet) private userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet private orderIds; // [order ids..]

    string[] marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => Market) private markets;

    mapping(bytes32 => Position) private positions; // key = user,market
    EnumerableSet.Bytes32Set private positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) private positionKeysForUser; // user => [position keys..]

    mapping(string => uint256) private OILong;
    mapping(string => uint256) private OIShort;

    mapping(address => uint256) private balances; // user => amount
    mapping(address => uint256) private lockedMargins; // user => amount
    EnumerableSet.AddressSet private usersWithLockedMargin; // [users...]
}
struct StoreFunding {
    mapping(string => int256) private fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256) private fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.
}
struct Store {
    StoreConstants constants;
    StoreContracts contracts;
    StoreVariables variables;
    StoreFunding funding;
}
struct State {
    address gov;
    uint constant BPS_DIVIDER = 10000;
    IStore store;

    Pool pool;
    Store store;
    Trade trade;
}

abstract contract CapStorage {
    State internal state;
}