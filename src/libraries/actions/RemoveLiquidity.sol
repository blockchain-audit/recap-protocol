// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";

import {Errors} from "../Errors.sol";

import {Events} from "../Events.sol";

import {Pool} from "../Pool.sol";

library RemoveLiquidity {

    using CLPToken for State;
    using Pool for State;

    function validateRemoveLiquidity(State storage state, uint256 amount) external {
        if(amount<=0)
        revert Errors.NULL_INPUT();
    }

    function executeRemoveLiquidity(State storage state, uint256 amount) external{
        address user = msg.sender;
        uint256 balance = state.poolBalance;
        uint256 clpSupply = store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = state.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * state.poolWithdrawalFee / BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        state.decrementPoolBalance(amountMinusFee);
        state.burnCLP(clpAmount);

        store.transferOut(amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, store.poolBalance);
    }

   
}