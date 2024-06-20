// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {State} from "../../Storage.sol";

import "../Event.sol";

library Liquidity {
    function addLiquidity(State storage state, uint256 amount, address from) external {
        require(amount > 0, "!amount");
        uint256 balance = state.pool.store.poolBalance();
        address user = from;
        state.pool.store.transferIn(user, amount);

        uint256 clpSupply = state.pool.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.pool.store.incrementPoolBalance(amount);
        state.pool.store.mintCLP(user, clpAmount);

        // emit AddLiquidity(user, amount, clpAmount, state.pool.store.poolBalance());
    }

    function addLiquidityThroughUniswap(
        State storage state,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee,
        address from,
        uint256 val
    ) external payable {
        require(poolFee > 0, "!poolFee");
        require(val != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = from;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = State.store.swapExactInputSingle{value: val}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = State.store.poolBalance();
        uint256 clpSupply = State.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        State.store.incrementPoolBalance(amountOut);
        State.store.mintCLP(user, clpAmount);

        // emit AddLiquidity(user, amountOut, clpAmount, state.poolBalance());
    }
}
