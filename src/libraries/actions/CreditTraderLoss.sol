// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";
import {Pool} from "../Pool.sol";
import {User} from "../User.sol";
import {Buffer} from "../Buffer.sol";


import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

library CreditTraderLoss {

    using CLPToken for State;
    using Pool for State;
    using User for State;
    using Buffer for State;

    function validateCreditTraderLoss(State storage state) external view {
        if (msg.sender != state.contracts.trade) {
            revert Errors.NOT_ALLOWED();
        }
    }

    function executeCreditTraderLoss(State storage state, address user, string memory market, uint256 amount) external {

        state.incrementBufferBalance(amount);
        state.decrementBalance(user, amount);

        uint256 lastPaid = state.variables.poolLastPaid;
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            state.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = state.variables.bufferBalance;
            uint256 bufferPayoutPeriod = state.variables.bufferPayoutPeriod;

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            state.incrementPoolBalance(amountToSendPool);
            state.decrementBufferBalance(amountToSendPool);
            state.setPoolLastPaid(_now);
        }

        emit Events.PoolPayIn(user, market, amount, amountToSendPool, state.variables.poolBalance, state.variables.bufferBalance);
    }
}