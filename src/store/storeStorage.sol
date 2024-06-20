//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13; 

import "../interfaces/IStore.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "lib/v3-periphery/contracts/interfaces/IQuoter.sol";

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

struct StateStore {
   
    address  gov;
    address  currency;
    address  clp;
    address  swapRouter;
    address  quoter;
    address  weth;
    address  trade;
    address  pool;
    // Variables
    //uint256 public poolFeeShare = 5000; // in bps
    // uint256 public keeperFeeShare = 1000; // in bps
    //uint256  poolWithdrawalFee = 10; // in bps
    // uint256  minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated
    uint256  bufferBalance;
    uint256  poolBalance;
    uint256  poolLastPaid;
    //uint256  bufferPayoutPeriod = 7 days;
    uint256  orderId;
}

struct Map{

    mapping(uint256 => IStore.Order)  orders;
    mapping(address => EnumerableSet.UintSet)  userOrderIds; // user => [order ids..]
    EnumerableSet.UintSet  orderIds; // [order ids..]

    string[]  marketList; // "ETH-USD", "BTC-USD", etc
    mapping(string => IStore.Market)  markets;

    mapping(bytes32 => IStore.Position)  positions; // key = user,market
    EnumerableSet.Bytes32Set  positionKeys; // [position keys..]
    mapping(address => EnumerableSet.Bytes32Set)  positionKeysForUser; // user => [position keys..]

    mapping(string => uint256)  OILong;
    mapping(string => uint256)  OIShort;

    mapping(address => uint256)  balances; // user => amount
    mapping(address => uint256)  lockedMargins; // user => amount
    EnumerableSet.AddressSet  usersWithLockedMargin; // [users...]

    // Funding
    mapping(string => int256)  fundingTrackers; // market => funding tracker (long) (short is opposite) // in UNIT * bps
    mapping(string => uint256)  fundingLastUpdated; // market => last time fundingTracker was updated. In seconds.

}

struct state{
    StateStore stateStore;
    Map map;

}

    abstract contract storeStorage {
    State internal state;
}


   
