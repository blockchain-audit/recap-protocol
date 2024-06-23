// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";


import "../interfaces/ICLP.sol";


library User {

    function incrementBalance(State storage state,address user, uint256 amount) external  {
        state.userBalances.balances[user] += amount;
    }

    function decrementBalance(State storage state,address user, uint256 amount) external  {
        require(amount <= state.userBalances.balances[user], "!balance");
        state.userBalances.balances[user] -= amount;
    }

    function getBalance(State storage state,address user) external view returns (uint256) {
        return state.userBalances.balances[user];
    }

}