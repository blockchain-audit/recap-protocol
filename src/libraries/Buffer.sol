pragma solidity ^0.8.24;

import {State} from "src/contracts/CapStorage.sol";

library Buffer {
    function incrementBufferBalance(State storage state, uint256 amount) external {
        state.balances.bufferBalance += amount;
    }

    function decrementBufferBalance(State storage state, uint256 amount) external {
        state.balances.bufferBalance -= amount;
    }
}