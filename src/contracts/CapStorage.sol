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

struct State {
    uint256 BPS_DIVIDER;
    uint256 MAX_FEE;
    uint256 MAX_KEEPER_FEE_SHARE;
    uint256 MAX_POOL_WITHDRAWAL_FEE;
    uint256 FUNDING_INTERVAL;

    address gov;
    address currency;
    address clp;
    address swapRouter;
    address quoter;
    address weth;
    address trade;
    address pool;

    uint256 poolFeeShare;
    uint256 keeperFeeShare;
    uint256 poolWithdrawalFee;
    uint256 minimumMarginLevel;
    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;
    uint256 bufferPayoutPeriod;
    uint256 orderId;
    mapping(uint256 => Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds;
    EnumerableSet.UintSet orderIds;
    string[] marketList;
    mapping(string => Market) markets;
    mapping(bytes32 => Position) positions;
    EnumerableSet.Bytes32Set positionKeys;
    mapping(address => EnumerableSet.Bytes32Set) positionKeysForUser;
    mapping(string => uint256) OILong;
    mapping(string => uint256) OIShort;
    mapping(address => uint256) balances;
    mapping(address => uint256) lockedMargins;
    EnumerableSet.AddressSet usersWithLockedMargin;

    mapping(string => int256) fundingTrackers;
    mapping(string => uint256) fundingLastUpdated;
}


abstract contract CapStorage {
    State internal state;
}