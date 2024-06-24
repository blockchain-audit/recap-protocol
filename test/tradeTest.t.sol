// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/contracts/Trade.sol";

contract TradeTest is Test {
    Trade trade;
    address addr1 = address(0x123);
    address addr2 = address(0x456);

    function setUp() public {
        trade=new Trade();
        // Fund addr1 with some ether
        vm.deal(addr1, 1 ether);
        // Fund addr2 with some ether
        vm.deal(addr2, 1 ether);
    }

    function testDeposit() public{
        
    }
}