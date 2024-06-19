// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Math {
    uint256 public constant BPS_DIVIDER = 10000;

    function calculateCLPAmount(uint256 amount, uint256 clpSupply, uint256 balance) external pure returns (uint256) {
        return balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
    }

    function calculateFeeAmount(uint256 amount, uint256 feePercentage) external pure returns (uint256) {
        return amount * feePercentage / BPS_DIVIDER;
    }

    function calculateAmountMinusFee(uint256 amount, uint256 feeAmount) external pure returns (uint256) {
        return amount - feeAmount;
    }

    function calculateAmountToSendPool(uint256 bufferBalance, uint256 lastPaid, uint256 bufferPayoutPeriod) external view returns (uint256) {
        uint256 amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;
        return amountToSendPool > bufferBalance ? bufferBalance : amountToSendPool;
    }
}