//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
// import "@hack/state.sol";
import {Storage} from  "@hack/state.sol";
library Buffer{
    function decrementBufferBalance(uint256 amount) external  {
        state.pools.bufferBalance -= amount;
    }
}