 pragma solidity ^0.8.24;
import "forge-std/console.sol";

import {State} from "src/CapStorage.sol";
import {PoolMethods} from "./PoolMethods.sol";
import {UserBalance} from "./UserBalance.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import {Buffer} from "./Buffer.sol";
library CreditTraderLoss {

    using Buffer for State;
    using PoolMethods for State;
    using UserBalance for State;

     function validateCreditTraderLoss(State storage state) view external {
        if(msg.sender != state.contractAddresses.trade) {
            revert Errors.NOT_TRADER();
        }
     }
     function executeCreditTraderLoss(State storage state, string memory market, uint256 amount) external {

        address user = msg.sender; 

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

            if (amountToSendPool > bufferBalance) {
                amountToSendPool = bufferBalance;
            }

            state.incrementPoolBalance(amountToSendPool);
            state.decrementBufferBalance(amountToSendPool);
            state.setPoolLastPaid(_now);
        }

        emit Events.PoolPayIn(user, market, amount, amountToSendPool, state.balances.poolBalance, state.balances.bufferBalance);
    }

 }
 