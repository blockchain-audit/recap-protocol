// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import "../../interfaces/ICLP.sol";

library CLPToken {

    using SafeERC20 for IERC20;

    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.contracts.clp).totalSupply();
    }

    function getUserPoolBalance(State storage state, address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(state.contracts.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(state.contracts.clp).balanceOf(user) * state.variables.poolBalance / clpSupply;
    }

    function mintCLP(State storage state, uint256 amount) external {
        ICLP(state.contracts.clp).mint(msg.sender, amount);
    }

    function burnCLP(State storage state, uint256 amount) external {
        ICLP(state.contracts.clp).burn(msg.sender, amount);
    }

    function transferIn(State storage state, uint256 amount) external {
        IERC20(state.contracts.currency).safeTransferFrom(msg.sender, state.contracts.pool, amount);
    }

    function transferOut(State storage state, uint256 amount) external {
        IERC20(state.contracts.currency).safeTransfer(msg.sender, amount);
    }
}