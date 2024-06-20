// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {CLPToken} from "../../CLPToken.sol";

import {Errors} from "../../Errors.sol";

import {Events} from "../../Events.sol";

import {Pool} from "../../Pool.sol";

import {Buffer} from "../../Buffer.sol";

import {User} from "../../User.sol";

import "../../../interfaces/ICLP.sol";

library DebitTraderProfit {

    using CLPToken for State;
    using Pool for State;
    using Buffer for State;    
    using User for State;

    function validateDebitTraderProfit(State storage state, uint amount) external{
        if(msg.sender!= state.addresses.trade)
            revert Errors.NOT_ALLOWED();

        uint256 bufferBalance = state.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.poolBalance;
            if(diffToPayFromPool < poolBalance)
            revert Errors.POOL_BALANCE();
    }
    }

    function executeDebitTraderProfit(State storage state, address user, string memory market, uint256 amount) external {

        if (amount == 0) return;

        uint256 bufferBalance = state.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.poolBalance;
            state.decrementBufferBalance(bufferBalance);
            state.decrementPoolBalance(diffToPayFromPool);
        } else {
            state.decrementBufferBalance(amount);
        }

        state.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.poolBalance, state.bufferBalance);
    }

    
    }
