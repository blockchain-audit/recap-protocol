 pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import {CLPMethods} from "../CLPMethods.sol";

import {PoolMethods} from "../PoolMethods.sol";

import {Events} from "../Events.sol";

import {UniswapMethods} from "../UniswapMethods.sol";

import {Math} from "../Math.sol";

library RemoveLiquidity {
     using CLPMethods for State;
    using PoolMethods for State;
    using UniswapMethods for State;
    using Math for State;
    using Math for uint256;

    function validateRemoveLiquidity(State storage state, uint256 amount) external {
        if (amount <= 0){
            revert Errors.NULL_AMOUNT();
        }
        if (state.balances.poolBalance <= 0 && state.getCLPSupply() <= 0){
            revert Errors.NULL_BALANCE();
        }
    }
    function executeRemoveLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;
        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 userBalance = state.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount.calculateFeeAmount(state.fees.poolWithdrawalFee);
        uint256 amountMinusFee = amount.calculateAmountMinusFee(feeAmount);

        // CLP amount
        uint256 clpAmount = amountMinusFee.calculateCLPAmount(clpSupply, balance);

        state.decrementPoolBalance(amountMinusFee);
        state.burnCLP(clpAmount);

        state.transferOut(user,amountMinusFee);

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, state.balances.poolBalance);

    }
        
}

 
 
 
 
        

    