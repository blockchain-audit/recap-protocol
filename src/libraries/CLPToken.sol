// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import "../interfaces/ICLP.sol";

library CLPToken {

    using SafeERC20 for IERC20;

    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.contractAddresses.clp).totalSupply();
    }

    function getUserPoolBalance(State storage state, address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(state.contractAddresses.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(state.contractAddresses.clp).balanceOf(user) * state.balances.poolBalance / clpSupply;
    }

    function mintCLP(State storage state, uint256 amount) external {
        ICLP(state.contractAddresses.clp).mint(msg.sender, amount);
    }

    function burnCLP(State storage state, uint256 amount) external {
        ICLP(state.contractAddresses.clp).burn(msg.sender, amount);
    }

    function transferIn(State storage state, uint256 amount) external {
        IERC20(state.contractAddresses.currency).safeTransferFrom(msg.sender, state.contractAddresses.pool, amount);
    }

    function transferOut(State storage state, address from, uint256 amount) external {
        IERC20(state.contractAddresses.currency).safeTransfer(from, amount);
    }

    function calculateCLPAmount(uint256 amount, uint256 clpSupply, uint256 balance) external pure returns (uint256) {
        return balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
    }
}