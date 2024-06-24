// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "src/CapStorage.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../../lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";

library UniswapMethods {

    using SafeERC20 for IERC20;

    function swapExactInputSingle(State storage state, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee) external returns (uint256 amountOut)
    {
        if (msg.value != 0) {
            tokenIn = state.contractAddresses.weth;
            amountIn = msg.value;
        } else {
            IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
            IERC20(tokenIn).forceApprove(address(state.contractAddresses.swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: state.contractAddresses.currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(state.contractAddresses.swapRouter).exactInputSingle{value: msg.value}(params);
    }
}