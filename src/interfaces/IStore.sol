// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.11;

import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

interface IStore {
    // Events
    event GovernanceUpdated(address indexed oldGov, address indexed newGov);

    // Structs
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


    function addOrUpdatePosition(Position memory position) external;

    function addOrder(Order memory order) external returns (uint256);

    function burnCLP(address user, uint256 amount) external;

    function decrementBalance(address user, uint256 amount) external;

    function decrementBufferBalance(uint256 amount) external;

    function decrementOI(string memory market, uint256 size, bool isLong) external;

    function decrementPoolBalance(uint256 amount) external;

    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut);



    function incrementBalance(address user, uint256 amount) external;

    function incrementBufferBalance(uint256 amount) external;

    function incrementOI(string memory market, uint256 size, bool isLong) external;

    function incrementPoolBalance(uint256 amount) external;


    function link(address _trade, address _pool, address _currency, address _clp) external;

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external;

    function lockMargin(address user, uint256 amount) external;


    function mintCLP(address user, uint256 amount) external;

    function removeOrder(uint256 _orderId) external;

    function removePosition(address user, string memory market) external;

    function setBufferPayoutPeriod(uint256 amount) external;

    function setFundingLastUpdated(string memory market, uint256 timestamp) external;

    function setKeeperFeeShare(uint256 amount) external;

    function setMarket(string memory market, Market memory marketInfo) external;

    function setMinimumMarginLevel(uint256 amount) external;

    function setPoolFeeShare(uint256 amount) external;

    function setPoolLastPaid(uint256 timestamp) external;

    function setPoolWithdrawalFee(uint256 amount) external;

    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        returns (uint256 amountOut);

    function transferIn(address user, uint256 amount) external;

    function transferOut(address user, uint256 amount) external;

    function unlockMargin(address user, uint256 amount) external;

    function updateFundingTracker(string memory market, int256 fundingIncrement) external;

    function updateGov(address _gov) external;

    function updateOrder(Order memory order) external;



}
