// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

pragma solidity ^0.8.24;

import "./interfaces/IStore.sol";

struct ChainLink {
    //= 10 ** 18;constant
    uint256 UNIT;
}
//     uint256  constant GRACE_PERIOD_TIME = 3600;

struct Store {
    // constants
    // uint256  constant MAX_FEE = 500; // in bps = 5%
    // uint256  constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    // uint256  constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    // uint256  constant FUNDING_INTERVAL = 1 hours; // In seconds.

    // contracts
    address currency;
    address swapRouter;
    address quoter;
    address weth;
    // // Variables
    // uint256  poolFeeShare = 5000; // in bps
    // uint256  keeperFeeShare = 1000; // in bps
    uint256 poolWithdrawalFee; // in bps
    // uint256  minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated
    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;
    // uint256  bufferPayoutPeriod = 7 days;
    uint256 orderId;
    mapping(uint256 => IStore.Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet orderIds; // [order ids..]
    string[] marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => IStore.Market) markets;
    mapping(bytes32 => IStore.Position) positions; // key = user,market
    EnumerableSet.Bytes32Set positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) positionKeysForUser; // user => [position keys..]
    mapping(string => uint256) OILong;
    mapping(string => uint256) OIShort;
    mapping(address => uint256) balances; // user => amount
    mapping(address => uint256) lockedMargins; // user => amount
    EnumerableSet.AddressSet usersWithLockedMargin; // [users...]
    // Funding
    mapping(string => int256) fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256) fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.
}

struct ContractAddress {
    address trade;
    address pool;
    address clp;
    address store;
}

struct RemainingData {
    //what is this address
    //find in store and pool  smart contracts
    address gov;
    // find to store and pool smart contracts
    uint256 BPS_DIVIDER;
}

struct Pool {
    address treasury;
    IStore store;
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
