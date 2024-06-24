// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../src/contracts/Trade.sol";
import {MockCapStorage} from "./MockCapStorage.sol";
import { State } from "../src/contracts/CapStorage.sol";
import {Test, console} from "forge-std/Test.sol";

import { CLPToken } from "../src/libraries/CLPToken.sol";

contract CalculateCLPAmountTest is Test {
    function setUp() public {
    }

    function testCalculateCLPAmount() public {
        uint256 amount = 1000;
        uint256 clpSupply = 5000;
        uint256 balance = 2000;
        uint256 expectedAmount = amount * clpSupply / balance;

        uint256 result = CLPToken.calculateCLPAmount(amount, clpSupply, balance);
        assertEq(result, expectedAmount, "Incorrect CLP amount calculated");
    }
}