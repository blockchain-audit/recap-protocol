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

library DebitTraderProfit{

    using PoolActions for State;
    using CLPToken for State;
    using Buffer for State;
    using UserActions for State;
    function validateDebitTraderProfit(State storage state, address user, string memory market, uint256 amount) external {
        if (amount == 0) return;

    }
    function executeDebitTraderProfit(State storage state, address user, string memory market, uint256 amount) external {
        uint256 bufferBalance = state.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.poolBalance;
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            state.decrementBufferBalance(bufferBalance);
            state.decrementPoolBalance(diffToPayFromPool);
        } else {
            state.decrementBufferBalance(amount);
        }

        state.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.poolBalance, state.bufferBalance);

    }


        
    

}