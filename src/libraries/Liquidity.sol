// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "src/CapStorage.sol";
import {CLPMethods} from "./CLPMethods.sol";
import {PoolMethods} from "./PoolMethods.sol";
import {UniswapMethods} from "./UniswapMethods.sol";
import {Errors} from "./Errors.sol";
import {Math} from "./Math.sol";
import {Events} from "./Events.sol";

library Liquidity {
    using CLPMethods for State;
    using PoolMethods for State;
    using UniswapMethods for State;
    using Math for State;
    using Math for uint256;

   function validateAddLiquidity(uint256 amount) external pure {
         if(amount == 0) {
            revert Errors.NULL_INPUT();
         }
     }

    function executeAddLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;
        state.transferIn(amount);

        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = amount.calculateCLPAmount(clpSupply, balance);

        state.incrementPoolBalance(amount);

        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, state.balances.poolBalance);
    }

    function validateAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint24 poolFee)
        external
        view
    {
        if (poolFee > 0) {
            revert Errors.NULL_INPUT();
        }
        if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
            revert Errors.NULL_INPUT();
        }
        if (address(state.contractAddresses.swapRouter) == address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

    function executeAddLiquidityThroughUniswap(
        State storage state,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee
    ) external {
        address user = msg.sender;

        uint256 amountOut = state.swapExactInputSingle(amountIn, amountOutMin, tokenIn, poolFee);
        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = amountOut.calculateCLPAmount(clpSupply, balance);

        state.incrementPoolBalance(amountOut);
        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.balances.poolBalance);
    }

    function validateRemoveLiquidity(State storage state, uint256 amount) view external {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
        if (state.balances.poolBalance == 0 || state.getCLPSupply() == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeRemoveLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();

        uint256 userBalance = state.getUserPoolBalance(user);
        if (amount > userBalance) {
            amount = userBalance;
        }
        uint256 feeAmount = amount.calculateFeeAmount(state.fees.poolWithdrawalFee);
        uint256 amountMinusFee = amount.calculateAmountMinusFee(feeAmount);

        uint256 clpAmount = amountMinusFee.calculateCLPAmount(clpSupply, balance);

        state.decrementPoolBalance(amountMinusFee);
        state.burnCLP(clpAmount);
        state.transferOut(msg.sender, amountMinusFee);

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, state.balances.poolBalance);
    }
}
