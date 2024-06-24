pragma solidity ^0.8.24;

library Events {
    event AddLiquidity(address indexed user, uint256 amount, uint256 clpAmount, uint256 poolBalance);
    event FeePaid(address indexed user, string market, uint256 fee, uint256 poolFee, bool isLiquidation);
    event GovernanceUpdated(address indexed oldGov, address indexed newGov);
    event PoolPayIn(address indexed user,string market,uint256 amount,uint256 bufferToPoolAmount,uint256 poolBalance,uint256 bufferBalance);
    event PoolPayOut(address indexed user, string market, uint256 amount, uint256 poolBalance, uint256 bufferBalance);
    event RemoveLiquidity(address indexed user, uint256 amount, uint256 feeAmount, uint256 clpAmount, uint256 poolBalance);
    event Deposit(address indexed user, uint256 amount);
    event FundingUpdated(string market, int256 fundingTracker, int256 fundingIncrement);
    event OrderCancelled(uint256 indexed orderId, address indexed user);
    event OrderCreated(uint256 indexed orderId, address indexed user, string market, bool isLong, uint256 margin, uint256 size, uint256 price, uint256 fee, uint8 orderType, bool isReduceOnly);
    event PositionDecreased( uint256 indexed orderId, address indexed user, string market, bool isLong, uint256 size, uint256 margin, uint256 price, uint256 positionMargin,
        uint256 positionSize, uint256 positionPrice, int256 fundingTracker, uint256 fee, uint256 keeperFee, int256 pnl, int256 fundingFee);
    event PositionIncreased( uint256 indexed orderId, address indexed user, string market, bool isLong, uint256 size, uint256 margin, uint256 price, uint256 positionMargin, uint256 positionSize,
        uint256 positionPrice,int256 fundingTracker, uint256 fee, uint256 keeperFee);
    event PositionLiquidated( address indexed user, string market, bool isLong, uint256 size, uint256 margin, uint256 price, uint256 fee, uint256 liquidatorFee);
    event Withdraw(address indexed user, uint256 amount);
}