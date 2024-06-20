// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {PoolActions} from "../PoolActions.sol";

import {Events} from "../Events.sol";

library AddLiquidity {

    using CLPToken for State;
    using PoolActions for State;

    function validateAddLiquidity(State storage state, uint256 amount) external view {
        if (amount <= 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function executeAddLiquidity(State storage state, uint256 amount) external {

        uint256 balance = state.poolBalance;

        state.transferIn(msg.sender,amount);

        uint256 clpSupply = state.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        
        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(msg.sender, amount, clpAmount, state.poolBalance);
    }
}