pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Buffer} from "../Buffer.sol";

import {UserActions} from "../UserActions.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {PoolActions} from "../PoolActions.sol";

import {Events} from "../Events.sol";

library CreditTraderLoss {

    using PoolActions for State;
    using CLPToken for State;
    using Buffer for State;
    using UserActions for State;

    function validateCreditTraderLoss(State storage state,address user, string memory market, uint256 amount) external {
        if (msg.sender != state.contractAddresses.trade){
            revert Errors.NOT_TRADER();
        }

    }
    function executeCreditTraderLoss(State storage state, address user, string memory market, uint256 amount) external {
        state.incrementBufferBalance(amount);
        state.decrementBalance(user, amount);

        uint256 lastPaid = state.balances.poolLastPaid;
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            state.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = state.balances.bufferBalance;
            uint256 bufferPayoutPeriod = state.buffer.bufferPayoutPeriod;

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            state.incrementPoolBalance(amountToSendPool);
            state.decrementBufferBalance(amountToSendPool);
            state.setPoolLastPaid(_now);
        }

        emit Events.PoolPayIn(user, market, amount, amountToSendPool, state.balances.poolBalance, state.balances.bufferBalance);

    }





}

        