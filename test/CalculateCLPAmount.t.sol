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

    // function testCalculateCLPAmount(uint256 amount, uint256 clpSupply, uint256 balance) public {
    //     CLPToken.CalculateCLPAmount(amount, clpSupply,balance);
    // }
}