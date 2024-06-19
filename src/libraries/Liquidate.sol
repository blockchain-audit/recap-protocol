
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "../state.sol";
import {RecapStorage} from "../state.sol";
import {Errors} from "./Errors.sol";
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
        uint256 balance = state.store.poolBalance;
        address user = msg.sender;
        state.transferIn(user, amount);
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
      //  state.incrementPoolBalance(amount);
        state.mintCLP(user, clpAmount);
       // emit AddLiquidity(user, amount, clpAmount, store.poolBalance());
    }
    function valied( address tokenIn, uint256 amountIn,uint24 poolFee)external view{
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

    }
    // function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
    //     external
    //     payable
    // {
       
    //     address user = msg.sender;

    //     // executes swap, tokens will be deposited to store contract
    //     uint256 amountOut = state.pool.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

    //     // add store supported liquidity
    //     uint256 balance = state.pool.store.poolBalance();
    //     uint256 clpSupply = state.pool.store.getCLPSupply();
    //     uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

    //     state.pool.store.incrementPoolBalance(amountOut);
    //     state.pool.store.mintCLP(user, clpAmount);

    //    // emit AddLiquidity(user, amountOut, clpAmount, store.poolBalance());
    // }

}