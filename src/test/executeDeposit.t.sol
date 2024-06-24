// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../contracts/CapStorage.sol";
import {Test} from "forge-std/Test.sol";
import {UserBalance} from "../libraries/UserBalance.sol";
import {Deposit} from "../libraries/tradeActions/Deposit.sol";

contract executeDepositTest is Test {
    function invariantTest(State memory state, address user, uint256 amount) external {
        uint256 initalBalance = UserBalance.getBalance(state, user);
        console.log("initial:          ",initalBalance);
        Deposit.executeDeposit(state, amount);
        uint256 finalBalance = UserBalance.getBalance(state, user);
        console.log("final:          ",finalBalance);
        assertEq(finalBalance, initalBalance + amount, "Invariant test failed for deposit operation");
    }
}
