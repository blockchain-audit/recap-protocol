// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

library AddLiquidityThroughUniswap {
    function validateAddLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee){
        
        if(!(msg.value != 0 || amountIn > 0 && tokenIn != address(0))||poolFee<0)
        revert Errors.NULL_INPUT();
        if(address(state.addresses.swapRouter) == address(0))
        revert Errors.NULL_ADDRESS();
    }

    function executeAddLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee){


    }
    
}