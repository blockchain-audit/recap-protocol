// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {Liquidity} from "../libraries/Liquidity.sol";

contract Pool is CapStorage{

    using Liquidity for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) public payable {
            state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, poolFee);
            state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);     
    }

    function removeLiquidity(uint256 amount) public {
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);       
    }
} 

