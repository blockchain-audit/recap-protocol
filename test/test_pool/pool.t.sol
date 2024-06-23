// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {RecapStorage, State} from "../../src/state.sol";
import {Test, console} from "forge-std/Test.sol";
import "../../src/pool.sol";

contract Pool is Test,RecapStorage{
    
    MainPool pool;
    address gov =vm.addr(1);
    function setUp()public{
        pool= new MainPool(gov);
    }
    function invariant_updateGov()public{
        address addrGovBefore= state.ContractAddress.gov;
        console.log(addrGovBefore);
        pool.updateGov(gov);
        assertEq(state.ContractAddress.gov !=addrGovBefore);

    } 
}