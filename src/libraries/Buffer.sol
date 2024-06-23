<<<<<<< HEAD

pragma solidity ^0.8.24;

import {State} from "src/contracts/CapStorage.sol";
=======
pragma solidity ^0.8.24;

import {State} from "src/CapStorage.sol";
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f

library Buffer {
    function incrementBufferBalance(State storage state, uint256 amount) external {
        state.balances.bufferBalance += amount;
    }

    function decrementBufferBalance(State storage state, uint256 amount) external {
        state.balances.bufferBalance -= amount;
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f
