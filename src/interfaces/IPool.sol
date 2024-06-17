// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

interface IPool {
    event AddLiquidity(address indexed user, uint256 amount, uint256 clpAmount, uint256 poolBalance);
    event FeePaid(address indexed user, string market, uint256 poolFee, bool isLiquidation);
    event GovernanceUpdated(address indexed oldGov,address indexed newGov);
    event PoolPayIn(
        address indexed user,
        string market,
        uint256 amount,
        uint256 bufferToPoolAmount,
        uint256 poolBalance,
        uint256,bufferBalance
    );
    event PoolPayOut(address indexed, string market)
}