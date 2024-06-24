pragma solidity ^0.8.24;

import {State} from "src/CapStorage.sol";
import {UserBalance} from "./UserBalance.sol";
import {Buffer} from "./Buffer.sol";
import {PoolMethods} from "./PoolMethods.sol";

import {Events} from "./Events.sol";
import {Errors} from "./Errors.sol";



library DebitTraderProfit {

    using Buffer for State;
    using UserBalance for State;
    using PoolMethods for State;


    function validateDebitTraderProfit(State storage state, address user, uint256 amount) view external {
        if (user != state.contractAddresses.trade) {
            revert Errors.NOT_TRADER();
        }
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeDebitTraderProfit(State storage state, address user, string memory market, uint256 amount) external {
        
        uint256 bufferBalance = state.balances.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.balances.poolBalance;
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            state.decrementBufferBalance(bufferBalance);
            state.decrementPoolBalance(diffToPayFromPool);
        } 
        else {
            state.decrementBufferBalance(amount);
        }

        state.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.balances.poolBalance, state.balances.bufferBalance);
    }
}