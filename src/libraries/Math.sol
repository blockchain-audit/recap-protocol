// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;


library Math {

    function calcClpAmount(uint amount, uint clpSupply, uint balance) internal pure returns (uint) {
        return clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
    }
        // uint256 feeAmount = amount * store.poolWithdrawalFee() / BPS_DIVIDER;

//     function calcFeeAmount(uint )
}
