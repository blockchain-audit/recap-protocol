 pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {PoolActions} from "../PoolActions.sol";

import {Events} from "../Events.sol";

library RemoveLiquidity {

    using CLPToken for State;
    using PoolActions for State;

    function validateRemoveLiquidity(State storage state, uint256 amount) external {
        if (amount <= 0){
            revert Errors.NULL_AMOUNT();
        }
        if (state.poolBalance <= 0 && state.getCLPSupply() <= 0){
            revert Errors.NULL_BALANCE();
        }
    }
    function executeRemoveLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;
        uint256 balance = state.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 userBalance = state.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * state.poolWithdrawalFee / state.BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        state.decrementPoolBalance(amountMinusFee);
        state.burnCLP(clpAmount);

        state.transferOut(user,amountMinusFee);

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, state.poolBalance);

    }
 
 
 
 
        

        

}