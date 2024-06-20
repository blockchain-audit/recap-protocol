// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../contracts/CapStorage.sol";

library Buffer {
    function incrementBufferBalance(State storage state,uint256 amount) external {
        state.variables.bufferBalance += amount;
    }

    function decrementBufferBalance(State storage state, uint256 amount) external {
        state.variables.bufferBalance -= amount;
    }
}