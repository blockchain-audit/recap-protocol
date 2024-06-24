pragma solidity ^0.8.24;

// import {Math} from "@src/libraries/Math.sol";
import {Math} from "src/libraries/Math.sol";
import {State} from "src/CapStorage.sol";
import {Test} from "forge-std/Test.sol";

contract MathTest is Test {
    function test_calculateFeeAmount() public {
        uint256 BPS_DIVIDER = 10000;
        uint256 amount = 100;
        uint256 feePercentage = 10;
        State storage s =   {};
        uint256 result = Math.calculateFeeAmount(s,amount, feePercentage);
        assertGt(result, amount, "its not correct");
    }
}
