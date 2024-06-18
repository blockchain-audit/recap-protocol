// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";

import {Errors} from "../Errors.sol";

library Liquidity {

    using CLPToken for State;

    function validateAddLiquidity(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function executeAddLiquidity(State storage state, uint256 amount, address user) external {
        require(amount > 0, "!amount");

        uint256 balance = state.poolBalance;

        state.transferIn(user, msg.sender, amount);

        uint256 clpSupply = state.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        
        // state.mintCLP(user, clpAmount);

        // emit AddLiquidity(user, amount, clpAmount, state.poolBalance());
    }
}