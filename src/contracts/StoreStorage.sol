// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


struct Constants {
    uint256 constant BPS_DIVIDER;
    uint256 constant MAX_FEE;
    uint256 constant MAX_KEEPER_FEE_SHARE;
    uint256 constant MAX_POOL_WITHDRAWAL_FEE;
    uint256 constant FUNDING_INTERVAL;
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
    uint256 public poolFeeShare;
    uint256 public keeperFeeShare;
    uint256 public poolWithdrawalFee;
    uint256 public minimumMarginLevel;

    uint256 public bufferBalance;
    uint256 public poolBalance;
    uint256 public poolLastPaid;

    uint256 public bufferPayoutPeriod;

    uint256 internal orderId;

    mapping(uint256 => Order) private orders;
    mapping(address => EnumerableSet.UintSet) private userOrderIds;
    EnumerableSet.UintSet private orderIds;

    string[] public marketList;
    mapping(string => Market) private markets;

    mapping(bytes32 => Position) private positions; 
    EnumerableSet.Bytes32Set private positionKeys;
    mapping(address => EnumerableSet.Bytes32Set) private positionKeysForUser;

    mapping(string => uint256) private OILong;
    mapping(string => uint256) private OIShort;

    mapping(address => uint256) private balances;
    mapping(address => uint256) private lockedMargins;
    EnumerableSet.AddressSet private usersWithLockedMargin;
}

struct Fundings {
    mapping(string => int256) private fundingTrackers;
    mapping(string => uint256) private fundingLastUpdated;
}