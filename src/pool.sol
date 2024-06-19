
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {RecapStorage, State} from "../src/state.sol";
import "../../src/library/PoolLibrary.sol";
import {Liquidate} from "./library/Liquidate.sol";

contract MainPool is RecapStorage{
    using PoolLibrary for State;
    using Liquidate for State;

     constructor(address _gov) {
        state.initialization(_gov);
    }
    function updateGov(address newGov)public{
        state.vailedGov(newGov);
        state.updateGov(state,newGov);
        
    }
    // function addLiquidity(uint256 amount)public{
    //     state.valiedAmountLiquidity(amount);
    //     state.addLiquidity(amount);
    // }
    // function addLiquidityThroughUniswap( address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)public{
    //     state.addLiquidityThroughUniswap( tokenIn,  amountIn,  amountOutMin,  poolFee);
    // }

}