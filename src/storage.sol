// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IStore.sol";
import "./interfaces/IChainlink.sol";
import "./interfaces/IPool.sol";
import "./interfaces/ICLP.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


struct Clp {
    address store;
}

struct Pool {
    uint256 BPS_DIVIDER;
    address gov;
    address trade;
    address treasury;
    IStore store;
}

struct Store {
    uint256 BPS_DIVIDER;
    uint256 MAX_FEE; // in bps = 5%
    uint256 MAX_KEEPER_FEE_SHARE; // in bps = 20%
    uint256 MAX_POOL_WITHDRAWAL_FEE; // in bps = 5%
    uint256 FUNDING_INTERVAL; // In seconds.
    // contracts
    address gov;
    address currency;
    address clp;
    address swapRouter;
    address quoter;
    address weth;
    address trade;
    address pool;
    // Variables
    uint256 poolFeeShare; // in bps
    uint256 keeperFeeShare; // in bps
    uint256 poolWithdrawalFee; // in bps
    uint256 minimumMarginLevel; // 20% in bps, at which account is liquidated
    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;
    uint256 bufferPayoutPeriod;
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
    mapping(string => uint256) fundingLastUpdated;
}

struct Trade {
    uint256 UNIT;
    uint256 BPS_DIVIDER;
    // Contracts
    address gov;
    IChainlink chainlink;
    IPool pool;
    IStore store;
}

struct State{
    Clp clp;
    Pool pool;
    Store store;
    Trade trade;
}

abstract contract Storage {
    State internal state;
}
