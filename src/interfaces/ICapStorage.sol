pragma solidity ^0.8.24;

interface ICapStorge{

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
}