// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../state.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./FUniswap.sol";
import "./Clp.sol";
import "./Transfer.sol";
import "./User.sol";

library Liquidate {
    using SafeERC20 for IERC20;
    using FUniswap for State;
    using Clp for State;
    using Transfer for State;
    using User for State;
    //Valiedation function

    function valiedAmountLiquidity(State storage state, uint256 amount) external view {
        if (amount > 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function valiedUniswapDetails(State storage state, address tokenIn, uint256 amountIn) external {
        if (address(state.store.swapRouter) != address(0)) {
            revert Errors.NULL_ADDRESS();
        }
        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = state.store.weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
            IERC20(tokenIn).forceApprove(address(state.store.swapRouter), amountIn);
        }
    }

    function validateRemoveLiquidity(State storage state, uint256 amount) external view {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
        if (state.store.poolBalance == 0 && state.getCLPSupply() == 0) {
            revert Errors.NULL_BALANCE();
        }
    }

    function valiedUniswap(State storage state, address tokenIn, uint256 amountIn, uint24 poolFee) external view {
        if (poolFee == 0) {
            revert Errors.NULL_INPUT();
        }
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");
    }
    //Function

    function executeAddLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.store.poolBalance;

        state.transferIn(user, amount);
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        state.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, state.store.poolBalance);
    }

    function executeAddLiquidityThroughUniswap(
        State storage state,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee
    ) external {
        //payable
        address user = msg.sender;

        uint256 amountOut = state.swapExactInputSingle(amountIn, amountOutMin, tokenIn, poolFee);
        // add store supported liquidity
        uint256 balance = state.store.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.incrementPoolBalance(amountOut);
        state.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.store.poolBalance);
    }

    function executeremoveLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;
        uint256 balance = state.store.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 userBalance = state.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;
        uint256 feeAmount = amount * state.store.poolWithdrawalFee / state.remainingData.BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;
        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        state.decrementPoolBalance(amountMinusFee);
        state.burnCLP(user, clpAmount);

        state.transferOut(user, amountMinusFee);

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, state.store.poolBalance);
    }
}
