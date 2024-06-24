// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {UpdateGov} from "src/libraries/UpdateGov.sol";
import "../interfaces/ICapStorage.sol";

struct ContractAddresses {
    address gov;
    address currency;
    address clp;
    address swapRouter;
    address quoter;
    address weth;
    address trade;
    address pool;
    address treasury; //we add it, it's variable from pool contract
}

struct Fees {
    uint256 poolFeeShare;
    uint256 keeperFeeShare;
    uint256 poolWithdrawalFee;
    uint256 minimumMarginLevel;
}

struct Balances {
    uint256 bufferBalance;
    uint256 poolBalance;
    uint256 poolLastPaid;
}

struct Buffer {
    uint256 bufferPayoutPeriod;
}

struct OrderData {
    mapping(uint256 => ICapStorge.Order) orders;
    mapping(address => EnumerableSet.UintSet) userOrderIds;
    EnumerableSet.UintSet orderIds;
}

struct MarketData {
    string[] marketList;
    mapping(string => ICapStorge.Market) markets;
    mapping(string => uint256) OILong;
    mapping(string => uint256) OIShort;
}

struct PositionData {
    mapping(bytes32 => ICapStorge.Position) positions;
    EnumerableSet.Bytes32Set positionKeys;
    mapping(address => EnumerableSet.Bytes32Set) positionKeysForUser;
}

struct UserBalances {
    mapping(address => uint256) balances;
    mapping(address => uint256) lockedMargins;
    EnumerableSet.AddressSet usersWithLockedMargin;
}

struct FundingData {
    mapping(string => int256) fundingTrackers;
    mapping(string => uint256) fundingLastUpdated;
}

struct State {
    ICapStorge.Market market;
    ICapStorge.Order order;
    ICapStorge.Position position;
    ContractAddresses contractAddresses;
    Fees fees;
    Balances balances;
    Buffer buffer;
    OrderData orderData;
    MarketData marketData;
    PositionData positionData;
    UserBalances userBalances;
    FundingData fundingData;
}

abstract contract CapStorage {
    State internal state;
}
