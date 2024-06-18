pragma solidity ^0.8.19;
import "./interfaces/IChainlink.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IStore.sol";
import "./interfaces/ITrade.sol";
import "./interfaces/ICLP.sol";


struct Pool {
    // uint256 public constant BPS_DIVIDER = 10000;
    // address public gov; 
    address trade;
    address treasury;
    // IStore public store;
}

struct Trade {
    uint256 constant UNIT = 10 ** 18;
    // uint256 public constant BPS_DIVIDER = 10000;
    // address public gov;
    IChainlink chainlink;
    IPool pool;
    // IStore public store;
}
struct StoreConstants {
    // uint256 public constant BPS_DIVIDER = 10000;
    uint256 constant MAX_FEE = 500; // in bps = 5%
    uint256 constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 constant FUNDING_INTERVAL = 1 hours; // In seconds. 
}
struct StoreContracts {
    // address public gov;
    address currency;
    address clp;

    address swapRouter;
    address quoter;
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

    uint256 orderId;    
}

struct StoreMaps {
    mapping(uint256 => Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet orderIds; // [order ids..]

    string[] marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => Market) markets;

    mapping(bytes32 => Position) positions; // key = user,market
    EnumerableSet.Bytes32Set positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) private positionKeysForUser; // user => [position keys..]

    mapping(string => uint256) OILong;
    mapping(string => uint256) OIShort;

    mapping(address => uint256) balances; // user => amount
    mapping(address => uint256) lockedMargins; // user => amount
    EnumerableSet.AddressSet usersWithLockedMargin; // [users...]
     
     // Funding
    mapping(string => int256) private fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256) private fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.
}
struct Store {
    StoreConstants cstoreConstants;
    StoreContracts storeContracts;
    StoreVariables storeVariables;
    StoreMaps      storeMaps;
}


struct State {
    address gov; 
    IStore store;
    uint256 constant BPS_DIVIDER = 10000;

    Pool pool;
    Trade trade;
    Store store; 
}

abstract contract CapStorage {
        
}