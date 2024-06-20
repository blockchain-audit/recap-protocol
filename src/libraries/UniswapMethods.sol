 pragma solidity ^0.8.24;

// import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
// import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
// import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "../../../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "forge-std/console.sol";
// import "/../../../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import {State} from "./../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import {Events} from "./Events.sol";
 

library UniswapMethods {
   using SafeERC20 for IERC20;

     function swapExactInputSingle(State storage state, address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee) external returns (uint256 amountOut)
    {

        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = state.weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).approve(address(state.swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: state.currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(state.swapRouter).exactInputSingle{value: msg.value}(params);
    }

    // // Function is not marked as view because it relies on calling non-view functions
    // // Not gas efficient so shouldnt be called on-chain
    // function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
    //     external
    //     returns (uint256 amountOut)
    // {
    //     return IQuoter(quoter).quoteExactInputSingle(tokenIn, currency, poolFee, amountIn, 0);
    // }

}
 