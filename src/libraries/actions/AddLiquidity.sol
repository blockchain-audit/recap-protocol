// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";
import {PoolActions} from "./PoolActions.sol";

import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

library AddLiquidity {

    using CLPToken for State;
    using PoolActions for State;

    function validateAddLiquidity(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeAddLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;

        state.transferIn(amount);

        uint256 balance = state.variables.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        state.mintCLP(clpAmount);
        emit Events.AddLiquidity(user, amount, clpAmount, state.variables.poolBalance);
    }
}