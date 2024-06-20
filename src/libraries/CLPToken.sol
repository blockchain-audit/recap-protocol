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
        return IERC20(state.addresses.clp).totalSupply();
    }

    function mintCLP(State storage state, uint256 amount) external {
        
        ICLP(state.addresses.clp).mint(msg.sender, amount);
    }

    function burnCLP(State storage state, uint256 amount) external {
        ICLP(state.addresses.clp).burn(msg.sender,amount);
    }

    function transferIn(State storage state,uint256 amount) external {

        IERC20(state.addresses.currency).safeTransferFrom(msg.sender, address(this), amount);
    }

    function transferOut(State storage state,address user, uint256 amount) external  {
        IERC20(state.addresses.currency).safeTransfer(user, amount);
    }

    function getUserPoolBalance(State storage state) external view returns (uint256) {
        uint256 clpSupply = IERC20(state.addresses.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(state.addresses.clp).balanceOf(msg.sender) * state.poolBalance / clpSupply;
    }
}