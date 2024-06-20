// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/IStore.sol";

struct CurrencyContracts {
    address gov;
    address currency;
    address clp;
}

struct SwapContracts {
    address swapRouter;
    address quoter;
    address weth;
}

struct PoolContracts {
    address trade;
    address pool; 
}

struct Fee {
    uint256 poolFeeShare; // in bps
    uint256 keeperFeeShare; // in bps
    uint256 poolWithdrawalFee; // in bps
    uint256 minimumMarginLevel;// in bps
}

struct PoolBalance {
    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;
}

struct Buffer {
    uint256 bufferPayoutPeriod;
}

struct OrderData {
    mapping(uint256 => IStore.Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet orderIds; // [order ids..]
}

struct MarketData {
    string[] marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => IStore.Market) markets;  
    mapping(string => uint256) OILong;
    mapping(string => uint256) OIShort;  
}

struct PositionData {
    mapping(bytes32 => IStore.Position) positions; // key = user,market
    EnumerableSet.Bytes32Set positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set) positionKeysForUser; // user => [position keys..]
}

struct UserData {
    mapping(address => uint256) balances; // user => amount
    mapping(address => uint256) lockedMargins; // user => amount
    EnumerableSet.AddressSet usersWithLockedMargin; // [users...]    
}

struct Funding {
    mapping(string => int256) fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256) fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.
}

struct State {
    CurrencyContracts currencyContracts;
    SwapContracts swapContracts;
    PoolContracts poolContracts;
    Fee fee;
    PoolBalance poolBalance;
    Buffer buffer;
    OrderData orderData;
    MarketData  marketData;
    PositionData positionData;
    UserData userData;
    Funding funding;
}

abstract contract CapStorage {
    State internal state;

    // constants
    uint256 constant BPS_DIVIDER = 10000;
    uint256 constant MAX_FEE = 500; // in bps = 5%
    uint256 constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 constant FUNDING_INTERVAL = 1 hours; // In seconds.

    // get functions
    function getBpsDivider() public pure returns (uint256) {
        return BPS_DIVIDER;
    }

    function getMaxFee() public pure returns (uint256) {
        return MAX_FEE;
    }

    function getMaxKeeperFeeShare() public pure returns (uint256) {
        return MAX_KEEPER_FEE_SHARE;
    }

    function getMaxPoolWithdrawalFee() public pure returns (uint256) {
        return MAX_POOL_WITHDRAWAL_FEE;
    }

    function getFundingInterval() public pure returns (uint256) {
        return FUNDING_INTERVAL;
    }
}












