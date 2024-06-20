// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {CLPToken} from "../../CLPToken.sol";
import {User} from "../../User.sol";

import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library Deposit {

    using CLPToken for State;
    using User for State;

    function validateDeposit(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeDeposit(State storage state, address user, uint256 amount) external {
        state.transferIn(amount);
        state.incrementBalance(user, amount);
        emit Events.Deposit(user, amount);
    }
}