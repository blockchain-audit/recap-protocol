// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import "../../interfaces/ICLP.sol";

library Pool {
    function incrementPoolBalance(State storage state ,uint256 amount) external {

        state.poolBalance += amount;
    }

    function decrementPoolBalance(State storage state, uint amount) external{
        state.poolBalance -= amount;
    }
}