// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {CLPToken} from "../../CLPToken.sol";
import {Pool} from "../../Pool.sol";
import {SwapMethods} from "../SwapMethods.sol";

import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library AddLiquidityThroughUniswap {

    using CLPToken for State;
    using Pool for State;
    using SwapMethods for State;

    function validateAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint24 poolFee) external view {
        if (poolFee > 0) {
            revert Errors.NULL_INPUT();
        }

        if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
            revert Errors.NULL_INPUT();
        }

        if (address(state.contracts.swapRouter) != address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

     function executeAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
    {
        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.swapExactInputSingle(amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.variables.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.incrementPoolBalance(amountOut);
        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.variables.poolBalance);
    }
}