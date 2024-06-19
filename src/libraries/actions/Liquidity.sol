// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";
import {PoolActions} from "./PoolActions.sol";

import {Errors} from "../Errors.sol";

library Liquidity {

    using CLPToken for State;
    using PoolActions for State;

    event AddLiquidity(address indexed user, uint256 amount, uint256 clpAmount, uint256 poolBalance);

    // Add liquidity
    function validateAddLiquidity(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function executeAddLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;

        state.transferIn(amount);

        uint256 balance = state.variables.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        state.mintCLP(clpAmount);
        emit AddLiquidity(user, amount, clpAmount, state.variables.poolBalance);
    }

    // Remove liquidity
    function validateRemoveLiquidity(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function executeRemoveLiquidity(State storage state, address user, uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = state.variables.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        // require(balance > 0 && clpSupply > 0, "!empty");

        // uint256 userBalance = store.getUserPoolBalance(user);
        // if (amount > userBalance) amount = userBalance;

        // uint256 feeAmount = amount * store.poolWithdrawalFee() / BPS_DIVIDER;
        // uint256 amountMinusFee = amount - feeAmount;

        // // CLP amount
        // uint256 clpAmount = amountMinusFee * clpSupply / balance;

        // store.decrementPoolBalance(amountMinusFee);
        // store.burnCLP(user, clpAmount);

        // store.transferOut(user, amountMinusFee);

        // emit RemoveLiquidity(user, amount, feeAmount, clpAmount, store.poolBalance());
    }
}