// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../src/contracts/Trade.sol";
import {MockCapStorage} from "./MockCapStorage.sol";
import { State } from "../src/contracts/CapStorage.sol";
import {Test, console} from "forge-std/Test.sol";

contract TradeTest is Test{

    function testDeposit() public {
        MockCapStorage capStorage = new MockCapStorage();

        address user = address(this);
        vm.deal(user, 100000000);
        uint256 amount = 100;

        // Perform deposit
        address trade = capStorage.getTradeAddress();
        Trade(trade).deposit(user, amount);

        // Retrieve updated state from mock storage
        // address clp = capStorage.state.contractAddresses.clp;
        // address clp = capStorage.getClp();
        // console.log(clp);

        // Assert user balance increased correctly
        // assertEq(capStorage.getUesrBalance(user), amount, "User balance should match deposited amount");

        // Assert pool balance updated correctly
        // Assert.equal(state.balances.poolBalance, amount, "Pool balance should match deposited amount");
    }
}
