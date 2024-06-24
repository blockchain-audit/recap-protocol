pragma solidity ^0.8.24;

import {Math} from "libraries/Math.sol";

import {Test} from "forge-std/Test.sol";

contract MathTest is Test {
    function test_calculateAmountMinusFee() public {
        uint256 BPS_DIVIDER = 10000;
        uint256 amount = 100;
        uint256 feePercentage = 10;
     
        uint256 result = Math.calculateAmountMinusFee( amount, feePercentage);
        assertLt(result, amount, "its not correct");
    }
}
