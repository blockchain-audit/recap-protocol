pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "./../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import {Events} from "./Events.sol";

library PoolActions {

    function incrementPoolBalance(State storage state, uint256 amount) external {
     state.poolBalance += amount;
     }
     function decrementPoolBalance(State storage state,uint256 amount) external  {
        state.poolBalance -= amount;
    }

    function setPoolLastPaid(State storage state,uint256 timestamp) external  {
        state.poolLastPaid = timestamp;
    }


     function getUserPoolBalance(State storage state, address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(state.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(state.clp).balanceOf(user) * state.poolBalance / clpSupply;
    }

    }
