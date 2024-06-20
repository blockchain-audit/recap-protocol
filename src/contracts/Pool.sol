// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {AddLiquidity} from "../libraries/actions/AddLiquidity.sol";
import {AddLiquidityThroughUniswap} from "../libraries/actions/AddLiquidityThroughUniswap.sol";

import {RemoveLiquidity} from "../libraries/actions/RemoveLiquidity.sol";

contract Pool is CapStorage{

    using AddLiquidity for State;
    using AddLiquidityThroughUniswap for State;
    using RemoveLiquidity for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    // msg.value - to send eth 
    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) public payable {
        state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, poolFee);
        state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }

    function removeLiquidity(uint256 amount) public payable {
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);
    }
} 