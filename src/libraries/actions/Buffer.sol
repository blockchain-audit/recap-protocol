pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import {Events} from "../Events.sol";

library Buffer {
    function incrementBufferBalance(State storage state, uint256 amount) external {
        state.bufferBalance += amount;
    }

    function decrementBufferBalance(State storage state, uint256 amount) external {
        state.bufferBalance -= amount;
    }

}
