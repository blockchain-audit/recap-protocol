
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
// import "./interfaces/IPool.sol";
import {RecapStorage, State} from "./state.sol";
import "../lib/PoolLibrary.sol";
contract Pool is RecapStorage{
    using PoolLibrary for State;
     constructor(address _gov) {
         state.initialization(_gov);

    }
    function updateGov(address newGov)public{
        state.updateGov(newGov);
    }
    function addLiquidity(uint256 amount)public{
        state.addLiquidity(amount);
    }
    function addLiquidityThroughUniswap( address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)public{
        state.addLiquidityThroughUniswap( tokenIn,  amountIn,  amountOutMin,  poolFee);
    }

}