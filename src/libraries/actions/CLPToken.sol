// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

library CLPToken {

    using SafeERC20 for IERC20;


    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.clp).totalSupply();
    }

    function incrementPoolBalance(State storage state, uint256 amount) external {
        // require(to == state.pool, "!contract");

        state.poolBalance += amount;
    }

    function transferIn(State storage state, address user, address to, uint256 amount) external {
        require(to == state.pool, "!contract");

        IERC20(state.currency).safeTransferFrom(user, to, amount);
    }
}