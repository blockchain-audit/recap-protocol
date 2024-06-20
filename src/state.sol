// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@hack/interfaces/IChainlink.sol";
import "@chainlink/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./interfaces/IStore.sol";
import "./interfaces/ICLP.sol";
import "./interfaces/IPool.sol";

struct ChainLink{
    AggregatorV3Interface sequencerUptimeFeed;
}
struct Pools {
    address  gov;
    address  trade;
    address  treasury;
    IStore  store;
}

struct StoreAddressContracts {
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
    mapping(uint256 => IStore.Order)  orders;
    mapping(address => EnumerableSet.UintSet)  userOrderIds;
    mapping(string => IStore.Market)  markets;
    mapping(bytes32 => IStore.Position)  positions;
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
    address  gov;
    IChainlink  chainlink;
    IPool  pool;
    IStore  store;
}

struct State {
    ChainLink chainLink;
    Pools pools;
    // StoreConstants storeConstants;
    StoreAddressContracts storeAddressContracts;
    StoreVariables storeVariables;
    StoreMapping storeMapping;
    StoreStruct storeStruct;
    StoreArray storeArray;
    Trade trade;

}

abstract contract Storage {
    State internal state;
    }
// contract aa{
//     uint a;
// }
