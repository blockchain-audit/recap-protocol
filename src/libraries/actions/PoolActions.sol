// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";

library PoolActions {

    function incrementPoolBalance(State storage state, uint256 amount) external {
        state.variables.poolBalance += amount;
    }

    function decrementPoolBalance(State storage state, uint256 amount) external {
        state.variables.poolBalance -= amount;
    }

    function setPoolLastPaid(State storage state, uint256 timestamp) external {
        state.variables.poolLastPaid = timestamp;
    }
}