// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../contracts/CapStorage.sol";

library User {
    function incrementBalance(State storage state, address user, uint256 amount) external {
        state.variables.balances[user] += amount;
    }

    function decrementBalance(State storage state, address user, uint256 amount) external {
        require(amount <= state.variables.balances[user], "!balance");
        state.variables.balances[user] -= amount;
    }

    function getBalance(State storage state, address user) external view returns (uint256) {
        return state.variables.balances[user];
    }
}