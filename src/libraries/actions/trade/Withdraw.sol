// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {User} from "../../User.sol";

import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library Withdraw {

    using User for State;

    function validateWithdraw(State storage state) external view {
        // if (poolFee == 0) {
        //     revert Errors.NULL_INPUT();
        // }
        // if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
        //     revert Errors.NULL_INPUT();
        // }
    }

    function executeWithdraw(State storage state, uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.getBalance(user);
        if (amount > balance) amount = balance;

        // int256 upl = getUpl(user)
    }
}