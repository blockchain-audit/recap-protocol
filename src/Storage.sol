// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./interfaces/IStore.sol";

struct Pool {
    address trade;
    address treasury;
    IStore store;
}

struct Contracts {
    address currency;
    address clp;
    address swapRouter;
    address quoter;
    address weth;
    address trade;
    address pool;
}

struct Variables {
    uint256 poolFeeShare; // in bps= 5000
    uint256 keeperFeeShare; // in bps = 1000
    uint256 poolWithdrawalFee; // in bps= 10
    uint256 minimumMarginLevel; // 20% in bps, at which account is liquidated  = 2000
    uint256 bufferPayoutPeriod; //= 7 days
    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;
    uint256 orderId;
}

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

struct Mapping {
    mapping(uint256 => Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet orderIds; // [order ids..]
    string[] marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => Market) markets;
    mapping(bytes32 => Position) positions; // key = user,market
    EnumerableSet.Bytes32Set positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) positionKeysForUser; // user => [position keys..]
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
    address gov;
    Pool pool;
    Contracts contracts;
    Variables variables;
    Mapping _mapping;
    Funding funding;
}

abstract contract Storage {
    State internal state;
}
