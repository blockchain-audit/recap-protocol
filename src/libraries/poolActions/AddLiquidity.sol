// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import {Events} from "../Events.sol";

import {CLPMethods} from "../CLPMethods.sol";

import {PoolMethods} from "../PoolMethods.sol";

import {UniswapMethods} from "../UniswapMethods.sol";

import {Math} from "../Math.sol";
library AddLiquidity {
    using CLPMethods for State;
    using PoolMethods for State;
    using UniswapMethods for State;
    using Math for State;
    using Math for uint256;

    function validateAddLiquidity (
        uint256 amount
    ) pure external  {
        if (amount <= 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function executeAddLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.balances.poolBalance;

        state.transferIn(user, amount);

        uint256 clpSupply = state.getCLPSupply();

        uint256 clpAmount = amount.calculateCLPAmount(clpSupply, balance);

        // uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);

        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(
            user,
            amount,
            clpAmount,
            state.balances.poolBalance
        );
    }
}
