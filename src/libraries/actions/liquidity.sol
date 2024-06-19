// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../../interfaces/IPool.sol";
import "../../interfaces/IStore.sol";

library Liquidity {
    uint256 public constant BPS_DIVIDER = 10000;
    IStore public store;

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = store.poolBalance();
        address user = msg.sender;
        store.transferIn(user, amount);

        uint256 clpSupply = store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        store.incrementPoolBalance(amount);
        store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amount, clpAmount, store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = store.poolBalance();
        uint256 clpSupply = store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        store.incrementPoolBalance(amountOut);
        store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amountOut, clpAmount, store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = store.poolBalance();
        uint256 clpSupply = store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * store.poolWithdrawalFee() / BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        store.decrementPoolBalance(amountMinusFee);
        store.burnCLP(user, clpAmount);

        store.transferOut(user, amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, store.poolBalance());
    }
}
