// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {CLPToken} from "../../CLPToken.sol";

import {Errors} from "../../Errors.sol";

import {Events} from "../../Events.sol";

import {Pool} from "../../Pool.sol";
import {User} from "../../User.sol";
import {Funding} from "../../Funding.sol";

library Withdraw {

    using CLPToken for State;
    using Pool for State;
    using User for State;
    using Funding for State;

    function validateWithdraw(State storage state, uint256 amount) external {
        if(amount<=0)
        revert Errors.NULL_INPUT();
        // equity after withdraw
        int256 upl = state.getUpl(user);
        uint256 lockedMargin = store.getLockedMargin(user);
        int256 equity = int256(balance - amount) + upl; 

        // adjust amount if equity after withdrawing < lockedMargin
        if (equity < int256(lockedMargin)) {
            int256 maxWithdrawableAmount;
            maxWithdrawableAmount = int256(balance) - int256(lockedMargin) + upl;

            if (maxWithdrawableAmount < 0) amount = 0;
            else amount = uint256(maxWithdrawableAmount);
        }

        if(int256(lockedMargin) > int256(balance - amount) + upl)
        revert Errors.NULL_INPUT();
    }

    function executeWithdraw(State storage state, uint256 amount) external {
        state.transferIn( amount);
        state.incrementBalance(msg.sender,amount);
        emit Events.Deposit(msg.sender, amount);
    }
}