// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IStore.sol";


struct CLP is ERC20 {
    address public store;
}



struct Pool is IPool {
    uint256 public constant BPS_DIVIDER = 10000;

    address public gov;
    address public trade;
    address public treasury;

    IStore public store;
}




struct Store is IStore {
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

    mapping(uint256 => Order)   orders;
    mapping(address => EnumerableSet.UintSet)   userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet   orderIds; // [order ids..]

    string[] public marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => Market)   markets;

    mapping(bytes32 => Position)   positions; // key = user,market
    EnumerableSet.Bytes32Set   positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set)   positionKeysForUser; // user => [position keys..]

    mapping(string => uint256)   OILong;
    mapping(string => uint256)   OIShort;

    mapping(address => uint256)   balances; // user => amount
    mapping(address => uint256)   lockedMargins; // user => amount
    EnumerableSet.AddressSet   usersWithLockedMargin; // [users...]

    // Funding
    mapping(string => int256)   fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256)   fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.
}




struct Trade is ITrade {
    uint256 public constant UNIT = 10 ** 18;
    uint256 public constant BPS_DIVIDER = 10000;

    // Contracts
    address public gov;
    IChainlink public chainlink;
    IPool public pool;
    IStore public store;
}


struct State {
CLP clp;
Pool pool;
Store store;
Trade trade;
}


abstract contract SizeStorage {
    State internal state;
}