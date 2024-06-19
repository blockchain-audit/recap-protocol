// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {AddLiquidity} from "../libraries/actions/AddLiquidity.sol";
import {AddLiquidityThroughUniswap} from "../libraries/actions/AddLiquidityThroughUniswap.sol";

contract Pool is CapStorage{

    using AddLiquidity for State;
    using AddLiquidityThroughUniswap for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)public payable{
        state.validateAddLiquidityThroughUniswap( tokenIn,  amountIn,  amountOutMin,  poolFee);
        state.executeAddLiquidityThroughUniswap( tokenIn,  amountIn,  amountOutMin,  poolFee);
    }

    

    
} 
