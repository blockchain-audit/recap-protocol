//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/contracts/Pool.sol";

contract PoolTest is Test {

    Pool public pool;

    function setUp() public {
        pool = new Pool();
        // pool.link(address(pool));
        vm.deal(address(this), 1000000000000);
    }

    function testAddLiquidity() public {
        uint256 amount = 10;
        pool.addLiquidity(amount);
    }
}
