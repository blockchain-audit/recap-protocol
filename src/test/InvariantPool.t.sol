// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {CapStorage, State} from "../CapStorage.sol";
import {Test, console} from "forge-std/Test.sol";
import {Errors} from "../libraries/Errors.sol";
import "../Pool.sol";
contract InvariantPool is Test{
    
    CapStorage public capStorage;
    Pool public pool;
    function setUp(address _poolAddress)public{
        pool = Pool(_poolAddress);
        capStorage = CapStorage(_poolAddress);
    }


    //בדיקה האם הכתובת תקינה 
    function invariant_GovCannotBeZeroAddress() public {
        vm.prank(address(this));
        CapStorage.State memory stateBefore = pool.getState();
        console.log(stateBefore.contractAddresses.gov);

      assertNotEq(stateBefore.contractAddresses.gov,address(0));
    }

    function test_FuzzUpdateGov(address randomAddress) public {
    if (randomAddress != address(0) && randomAddress != address(this)) {
        vm.prank(address(this));
        pool.updateGov(randomAddress);
        assertEq(capStorage.state.contractAddresses.gov, randomAddress);
    } else {
        vm.prank(address(this));
        vm.expectRevert(abi.encodeWithSelector(Errors.NULL_ADDRESS.selector));
        pool.updateGov(randomAddress);
    }
}

    
}