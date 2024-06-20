// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../state.sol";
import "../../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import {RecapStorage} from "../state.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./FIliquidate.sol";
import "./Clp.sol";
import "./Transfer.sol";
import "./User.sol";

library Liquidate {
    using SafeERC20 for IERC20;
    using FLiquidate for State;
    using Clp for State;
    using Transfer for State;
    using User for State;

    function valiedAmountLiquidity(uint256 amount) external view {
        if (amount > 0) {
            revert Errors.NULL_AMOUNT();
        }
    }

    function addLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.store.poolBalance;

        state.transferIn(user, amount);
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        state.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, state.store.poolBalance);
    }

    function valiedUniswap(address tokenIn, uint256 amountIn, uint24 poolFee) external view {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");
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

    function addLiquidityThroughUniswap(
        State storage state,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee
    ) external {
        //payable
        address user = msg.sender;

        uint256 amountOut = state.swapExactInputSingle(user, amountIn, amountOutMin, tokenIn, poolFee);
        // add store supported liquidity
        uint256 balance = state.store.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.incrementPoolBalance(amountOut);
        state.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.store.poolBalance);
    }

    function removeLiquidity(State storage state, uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = state.store.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

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
