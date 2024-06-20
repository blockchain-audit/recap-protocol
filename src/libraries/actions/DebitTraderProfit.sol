// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Pool} from "../Pool.sol";
import {User} from "../User.sol";
import {Buffer} from "../Buffer.sol";

import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

library DebitTraderProfit {

    using Pool for State;
    using User for State;
    using Buffer for State;

    function validateDebitTraderProfit(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }

        if (msg.sender != state.contracts.trade) {
            revert Errors.NOT_TRADER();
        }
    }

    function executeDebitTraderProfit(State storage state, string memory market, uint256 amount) external {
        address user = msg.sender;

        uint256 bufferBalance = state.variables.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.variables.poolBalance;
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            state.decrementBufferBalance(bufferBalance);
            state.decrementPoolBalance(diffToPayFromPool);
        } else {
            state.decrementBufferBalance(amount);
        }

        state.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.variables.poolBalance, state.variables.bufferBalance);
    }
}