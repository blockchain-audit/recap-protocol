// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {CLPToken} from "../../CLPToken.sol";

import {Errors} from "../../Errors.sol";

import {Events} from "../../Events.sol";

import {Pool} from "../../Pool.sol";
import {User} from "../../User.sol";

library Deposit {

    using CLPToken for State;
    using Pool for State;
    using User for State;

    function validateDeposit(State storage state, uint256 amount) external {
        if(amount<=0)
        revert Errors.NULL_INPUT();
    }

    function executeDeposit(State storage state, uint256 amount) external {
        state.transferIn( amount);
        state.incrementBalance(msg.sender,amount);
        emit Events.Deposit(msg.sender, amount);
    }
}