// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@hack/interfaces/IChainlink.sol";
import "@hack/interfaces/IPool.sol";
import "@hack/interfaces/IStore.sol";
import "@chainlink/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/IStore.sol";
import "./interfaces/ICLP.sol";

struct chinLink{
    uint256  UNIT ;
    uint256 GRACE_PERIOD_TIME  ;
    AggregatorV3Interface sequencerUptimeFeed;
}
struct pool {
    uint256 BPS_DIVIDER   ;
    address  gov;
    address  trade;
    address  treasury;
    IStore  store;
}

struct StoreConstants{
    uint256 BPS_DIVIDER ;
    uint256 MAX_FEE ;
    uint256 MAX_KEEPER_FEE_SHARE ;
    uint256 MAX_POOL_WITHDRAWAL_FEE ;
    uint256 FUNDING_INTERVAL ;
}
struct storeaddressContracts {
    address  gov;
    address  currency;
    address  clp;
    address  swapRouter;
    address  quoter;
    address  weth;
    address  trade;
    address  pool;
}
struct StoreVariables{
    uint256  poolFeeShare;
    uint256  keeperFeeShare ;
    uint256  poolWithdrawalFee ;
    uint256  minimumMarginLevel ;
    uint256  bufferBalance;
    uint256  poolBalance;
    uint256  poolLastPaid;
    uint256  bufferPayoutPeriod ;
    uint256  orderId;
}
struct StoreMapping {
    mapping(uint256 => Order)  orders;
    mapping(address => EnumerableSet.UintSet)  userOrderIds;
    // mapping(string => Market)  markets;
    // mapping(bytes32 => Position)  positions;
    mapping(address => EnumerableSet.Bytes32Set)  positionKeysForUser;
    mapping(string => uint256)  OILong;
    mapping(string => uint256)  OIShort;
    mapping(address => uint256)  balances;
    mapping(address => uint256)  lockedMargins;
    mapping(string => int256)  fundingTrackers;
    mapping(string => uint256)  fundingLastUpdated;
}

struct StoreStruct{
    EnumerableSet.UintSet  orderIds;
    EnumerableSet.Bytes32Set  positionKeys;
    EnumerableSet.AddressSet  usersWithLockedMargin;
}

struct StoreArray {
    string[]  marketList;
}

struct Trade {
    uint256  UNIT ;
    uint256  BPS_DIVIDER ;
    address  gov;
    IChainlink  chainlink;
    IPool  pool;
    IStore  store;
}

contract aa{
    uint a;
}