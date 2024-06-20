
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "../state.sol";
import {RecapStorage} from "../state.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

import "./FIliquidate.sol";
import "./Clp.sol";

library Liquidate  {
    using FLiquidate for State;
    using Clp for State;

 function valiedAmountLiquidity(uint256 amount)external view{
        if(amount > 0){
            revert Errors.NULL_AMOUNT();
        }
    }
    function addLiquidity(State storage state,uint256 amount) external {
        address user = msg.sender;

        uint256 balance = state.store.poolBalance;

        state.transferIn(user, amount);
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.incrementPoolBalance(amount);
        state.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, state.store.poolBalance);
    }
    function valiedUniswap( address tokenIn, uint256 amountIn,uint24 poolFee)external view{
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

    }
    function valiedUniswapDetails(address tokenIn,uint256 amountIn)external {
            if(address(swapRouter) != address(0)){
                revert Errors.NULL_ADDRESS();
            }
        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).safeApprove(address(swapRouter), amountIn);
        }

    }
    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)external payable{
       
        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.store.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.incrementPoolBalance(amountOut);
        state.mintCLP(user, clpAmount);

       emit Events.AddLiquidity(user, amountOut, clpAmount, state.store.poolBalance);
    }

}