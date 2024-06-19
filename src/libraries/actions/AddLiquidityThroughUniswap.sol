pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {UniswapMethods} from "./UniswapMethods.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";

import {Errors} from "../Errors.sol";

import {PoolActions} from "./PoolActions.sol";

import {Events} from "../Events.sol";

library AddLiquidityThroughUniswap {

    using PoolActions for State;
    using CLPToken for State;
    using UniswapMethods for State;

    function validateAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external view 
    {
        if (poolFee <= 0) {
            revert Errors.NULL_INPUT();
        }
        if (msg.value <= 0 || amountIn < 0 && tokenIn == address(0)){
            revert Errors.NULL_INPUT();
        }
    }

    function executeAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external 
    {
        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.swapExactInputSingle{value: msg.value}(msg.sender, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.incrementPoolBalance(amountOut);
        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(msg.sender, amountOut, clpAmount, state.poolBalance);
    }
}