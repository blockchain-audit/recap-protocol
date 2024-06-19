// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {AddLiquidityThroughUniswap} from "../libraries/actions/AddLiquidityThroughUniswap.sol";

import {AddLiquidity} from "../libraries/actions/AddLiquidity.sol";

contract Pool is CapStorage{
    using AddLiquidityThroughUniswap for State;
    using AddLiquidity for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }
  function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        state.validateAddLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee);
        state.executeAddLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee);
    }
} 