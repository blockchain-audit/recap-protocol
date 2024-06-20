// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../state.sol";

library Buffer {
    // function setBufferPayoutPeriod(uint256 amount) external onlyGov {
    //     bufferPayoutPeriod = amount;
    // }
    // Buffer
    function incrementBufferBalance(State storage state, uint256 amount) external {
        state.store.bufferBalance += amount;
    }

    function decrementBufferBalance(State storage state, uint256 amount) external {
        state.store.bufferBalance -= amount;
    }
}
