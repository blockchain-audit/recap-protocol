// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";
import {PoolActions} from "./PoolActions.sol";
import {SwapMethods} from "./SwapMethods.sol";

import {Errors} from "../Errors.sol";

library Liquidate {

    using CLPToken for State;
    using PoolActions for State;
    using SwapMethods fror State;

    event AddLiquidity(address indexed user, uint256 amount, uint256 clpAmount, uint256 poolBalance);

    // Add liquidity
    function validateAddLiquidity(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
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

    function validateAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external view {
        if (poolFee > 0) {
            revert Errors.NULL_INPUT();
        }

        if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
            revert Errors.NULL_INPUT();
        }

        if (address(state.contracts.swapRouter) != address(0)) {
            Errors.NULL_ADDRESS();
        }
    }

     function executeAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.swapExactInputSingle{value: msg.value}(amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.variables.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.incrementPoolBalance(amountOut);
        state.mintCLP(clpAmount);

        emit AddLiquidity(amountOut, clpAmount, store.variables.poolBalance);
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