// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";
import {PoolActions} from "./PoolActions.sol";
import {UserBalance} from "./UserBalance.sol";
import {Buffer} from "./Buffer.sol";

import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

library DebitTraderProfit {

    using CLPToken for State;
    using PoolActions for State;
    using UserBalance for State;
    using Buffer for State;

    function validateDebitTraderProfit(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeDebitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {

        uint256 bufferBalance = store.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = store.poolBalance();
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            store.decrementBufferBalance(bufferBalance);
            store.decrementPoolBalance(diffToPayFromPool);
        } else {
            store.decrementBufferBalance(amount);
        }

        store.incrementBalance(user, amount);

        emit PoolPayOut(user, market, amount, store.poolBalance(), store.bufferBalance());
    }
}