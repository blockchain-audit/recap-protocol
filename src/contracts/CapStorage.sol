// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

struct Market {
    string symbol;
    address feed;
    uint16 minSettlementTime;
    uint16 maxLeverage;
    uint32 fee;
    uint32 fundingFactor;
    uint256 maxOI;
    uint256 minSize;
}

struct Order {
    bool isLong;
    bool isReduceOnly;
    uint8 orderType;
    uint72 orderId;
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

struct Constants {
    // uint256 constant BPS_DIVIDER = 10000;
    // uint256 constant MAX_FEE = 500; // in bps = 5%
    // uint256 constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    // uint256 constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    // uint256 constant FUNDING_INTERVAL = 1 hours; // In seconds.

    uint256 BPS_DIVIDER;
    uint256 MAX_FEE; // in bps = 5%
    uint256 MAX_KEEPER_FEE_SHARE; // in bps = 20%
    uint256 MAX_POOL_WITHDRAWAL_FEE; // in bps = 5%
    uint256 FUNDING_INTERVAL; // In seconds.
}

struct Contracts {
    address gov;
    address currency;
    address clp;

    address swapRouter;
    address quoter;
    address weth;

    address trade;
    address pool;
}

struct Variables {
    // uint256 poolFeeShare = 5000; // in bps
    // uint256 keeperFeeShare = 1000; // in bps
    // uint256 poolWithdrawalFee = 10; // in bps
    // uint256 minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated

    uint256 poolFeeShare; // in bps
    uint256 keeperFeeShare; // in bps
    uint256 poolWithdrawalFee; // in bps
    uint256 minimumMarginLevel; // 20% in bps, at which account is liquidated

    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;

    // uint256 bufferPayoutPeriod = 7 days;

    uint256 bufferPayoutPeriod;

    uint256 orderId;

    mapping(uint256 => Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet orderIds; // [order ids..]

    string[] marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => Market) markets;

    mapping(bytes32 => Position) positions; // key = user,market
    EnumerableSet.Bytes32Set positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) userPositionKeys; // user => [position keys..]

    mapping(string => uint256) OILong;
    mapping(string => uint256) OIShort;

    mapping(address => uint256) balances; // user => amount
    mapping(address => uint256) lockedMargins; // user => amount
    EnumerableSet.AddressSet usersWithLockedMargin; // [users...]
}

struct Funding {
    mapping(string => int256) fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256) fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.
}

struct State {
    Constants constants;
    Contracts contracts;
    Variables variables;
    Funding funding;
    address treasury;
}

abstract contract CapStorage {
    State internal state;
}