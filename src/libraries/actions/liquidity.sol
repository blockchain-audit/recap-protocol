// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../../interfaces/IPool.sol";
import "../../interfaces/IStore.sol";
import "../Events.sol";
import {State} from "./state.sol";

library Liquidity {
    uint256 public constant BPS_DIVIDER = 10000;

    // using State for State.pool.store;

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = State.store.poolBalance();
        address user = msg.sender;
        State.store.transferIn(user, amount);

        uint256 clpSupply = State.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        State.store.incrementPoolBalance(amount);
        State.store.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, State.store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut =
            State.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = State.store.poolBalance();
        uint256 clpSupply = State.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        State.store.incrementPoolBalance(amountOut);
        State.store.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, State.store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = State.store.poolBalance();
        uint256 clpSupply = State.store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = State.store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * State.store.poolWithdrawalFee() / BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        State.store.decrementPoolBalance(amountMinusFee);
        State.store.burnCLP(user, clpAmount);

        State.store.transferOut(user, amountMinusFee);

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, State.store.poolBalance());
    }
}
