// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../src/contracts/Trade.sol";
import "./MockCapStorage.sol";

import {Test, console} from "forge-std/Test.sol";

contract TradeTest is Test{

    function testDeposit() public {
        MockCapStorage capStorage = new MockCapStorage();

        address user = address(this);
        vm.deal(user, 10000000);
        console.log("User balance:", address(user).balance);
        uint256 amount = 100;

        // Simulate user balance in mock storage (if needed)
        // capStorage.setUserBalance(user, 0);

        // Perform deposit
        uint256 userBalance = capStorage.getUserBalance(user);
        // Log user balance for debugging
        console.log("User balance before deposit:", userBalance);

        address trade = capStorage.getTradeAddress();
        console.log(trade);
        Trade(trade).deposit(user, amount);

        // Retrieve updated user balance from mock storage
        userBalance = capStorage.getUserBalance(user);

        // Log user balance for debugging
        console.log("User balance after deposit:", userBalance);

        // Assert user balance increased correctly
        // assertEq(userBalance == amount, "User balance should match deposited amount");

        // Additional assertions or checks can be added here
        // ...

        // Log additional state for debugging if needed
        // console.log("Pool balance:", state.balances.poolBalance);
    }
}
