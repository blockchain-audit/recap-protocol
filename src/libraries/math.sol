// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

library Math {
    uint256 public constant BPS_DIVIDER = 10000;

    function calculateCLPAmount(uint256 amount, uint256 clpSupply, uint256 balance) internal pure returns (uint256) {
        return balance == 0 || clpSupply == 0 ? amount : (amount * clpSupply) / balance;
    }

    function calculateFeeAmount(uint256 amount, uint256 feeBps) internal pure returns (uint256) {
        return (amount * feeBps) / BPS_DIVIDER;
    }

    function calculateAmountToSendPool(uint256 bufferBalance, uint256 timePassed, uint256 bufferPayoutPeriod) internal pure returns (uint256) {
        uint256 amountToSendPool = (bufferBalance * timePassed) / bufferPayoutPeriod;
        return amountToSendPool > bufferBalance ? bufferBalance : amountToSendPool;
    }

    function calculatePoolFee(uint256 fee, uint256 poolFeeShare) internal pure returns (uint256) {
        return (fee * poolFeeShare) / BPS_DIVIDER;
    }
}
