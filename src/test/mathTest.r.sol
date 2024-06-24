
pragma solidity ^0.8.24;
import {Math} from "src/libraries/Math.sol";
import {Test} from "forge-std/Test.sol";

contract MathTest is Test {
    uint256 constant BUFFER_BALANCE = 1000;
    uint256 constant BUFFER_PAYOUT_PERIOD = 86400; // יום אחד ב-שניות

    function test_calculateAmountToSendPool() public {
        uint256 BUFFER_BALANCE = 1000;
        uint256 BUFFER_PAYOUT_PERIOD = 500;
        uint256 lastPaid = 3;
        uint256 expectedAmount = BUFFER_BALANCE * 3600 / BUFFER_PAYOUT_PERIOD;
        uint256 result = Math.calculateAmountToSendPool(BUFFER_BALANCE, lastPaid, BUFFER_PAYOUT_PERIOD);
        assertLt(result, expectedAmount, "Incorrect amount sent to pool within period");
    }
}
