// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Math {
    function calcClpAmount(uint256 balance, uint256 clpSupply, uint256 amount) external pure returns (uint256) {
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
        return clpAmount;
    }
}
