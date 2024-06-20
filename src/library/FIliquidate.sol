
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import {RecapStorage} from "../state.sol";
import "../state.sol";
library FLiquidate {
   
   function incrementPoolBalance(State storage state,uint256 amount) external  {
        state.store.poolBalance += amount;
    }
    // Uniswap methods
    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)external payable
    returns (uint256 amountOut)
    {
    
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(swapRouter).exactInputSingle{value: msg.value}(params);
    }
}