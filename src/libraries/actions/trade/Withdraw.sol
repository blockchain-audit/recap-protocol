// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {User} from "../../User.sol";
import {PositionLogic} from "./PositionLogic.sol";
import {CLPToken} from "../../CLPToken.sol";

import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library Withdraw {

    using User for State;
    using PositionLogic for State;
    using CLPToken for State;

    function validateWithdraw(State storage state, uint256 amount) external view {
        address user = msg.sender;

        uint256 balance = state.getBalance(user);
        if (amount > balance) amount = balance;

        int256 upl = state.getUpl(user);

        uint256 lockedMargin = state.userBalances.lockedMargins[user];
        int256 equity = int256(balance - amount) + upl; 

        if (equity < int256(lockedMargin)) {
            int256 maxWithdrawableAmount;
            maxWithdrawableAmount = int256(balance) - int256(lockedMargin) + upl;

            if (maxWithdrawableAmount < 0) amount = 0;
            else amount = uint256(maxWithdrawableAmount);
        }

        if (amount <= 0) {
            revert Errors.NULL_INPUT();
        }

        if (int256(lockedMargin) > int256(balance - amount) + upl) {
            revert Errors.NULL_EQUITY();
        }
    }

    function executeWithdraw(State storage state, uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.getBalance(user);
        if (amount > balance) amount = balance;

        int256 upl = state.getUpl(user);

        uint256 lockedMargin = state.userBalances.lockedMargins[user];
        int256 equity = int256(balance - amount) + upl; 

        if (equity < int256(lockedMargin)) {
            int256 maxWithdrawableAmount;
            maxWithdrawableAmount = int256(balance) - int256(lockedMargin) + upl;

            if (maxWithdrawableAmount < 0) amount = 0;
            else amount = uint256(maxWithdrawableAmount);
        }

        state.decrementBalance(user, amount);
        state.transferOut(msg.sender, amount);
        emit Events.Withdraw(msg.sender, amount);
    }
}