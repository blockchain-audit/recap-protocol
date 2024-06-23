// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/contracts/Pool.sol";

contract PoolTest is Test {
    Pool pool;
    address addr1 = address(0x123);
    address addr2 = address(0x456);

    function setUp() public {
        // Deploy the Pool contract
        pool = new Pool();
        // Fund addr1 with some ether
        vm.deal(addr1, 1 ether);
        // Fund addr2 with some ether
        vm.deal(addr2, 1 ether);
    }

    function testAddLiquidity() public {
        vm.startPrank(addr1);
        uint256 amount = 0.1 ether;
        pool.addLiquidity{value: amount}(amount);
        vm.stopPrank();
    }
}