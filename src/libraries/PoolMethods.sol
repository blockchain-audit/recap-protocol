// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

<<<<<<< HEAD
import {State} from "../contracts/CapStorage.sol";
=======
import {State} from "../CapStorage.sol";
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f

import {CLPMethods} from "./CLPMethods.sol";

import {Errors} from "./Errors.sol";

library PoolMethods {

    using SafeERC20 for IERC20;

    using CLPMethods for State;
    function incrementPoolBalance(State storage state, uint256 amount) external {
        state.balances.poolBalance += amount;
    }

    function decrementPoolBalance(State storage state, uint256 amount) external {
        state.balances.poolBalance -= amount;
    }
    function setPoolLastPaid(State storage state, uint256 timestamp) external {
        state.balances.poolLastPaid = timestamp;
    }

    function getUserPoolBalance(State storage state, address user) external view returns (uint256) {
        uint256 clpSupply = state.getCLPSupply();
        if (clpSupply == 0) return 0;
        return IERC20(state.contractAddresses.clp).balanceOf(user) * state.balances.poolBalance / clpSupply;
    }
}