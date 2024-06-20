// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {RecapStorage, State} from "../src/state.sol";
import {Liquidate} from "./library/Liquidate.sol";
import {PoolLibrary} from "./library/PoolLibrary.sol";

contract MainPool is RecapStorage {
    using PoolLibrary for State;
    using Liquidate for State;

    constructor(address _gov) {
        state.initialization(_gov);
    }

    function updateGov(address newGov) public {
        state.vailedGov(newGov);
        state.updateGov(state, newGov);
    }

    function addLiquidity(uint256 amount) public {
        state.valiedAmountLiquidity(amount);
        state.addLiquidity(amount);
    }

    function addLiquidityToUniswap(
        address user,
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenIn,
        uint24 poolFee
    ) public {
        state.valiedUniswapDetails(tokenIn, amountIn);
        state.addLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }
}
