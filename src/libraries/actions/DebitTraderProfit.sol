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
        if (msg.sender != state.contracts.trade) {
            revert Errors.NULL_ADDRESS();
        }

        uint256 bufferBalance = state.variables.bufferBalance;
        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.variables.poolBalance;
            if (diffToPayFromPool < poolBalance) {
                revert Errors.POOL_BALANCE();
            }
        }
    }

    function executeDebitTraderProfit(State storage state, address user, string memory market, uint256 amount) external {
        if (amount == 0) return;

        uint256 bufferBalance = state.variables.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            state.decrementBufferBalance(bufferBalance);
            state.decrementPoolBalance(diffToPayFromPool);
        } else {
            state.decrementBufferBalance(amount);
        }

        state.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.variables.poolBalance, state.variables.bufferBalance);
    }
}