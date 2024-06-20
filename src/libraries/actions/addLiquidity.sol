// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Liquidate{


    function validateAddLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = store.poolBalance();
        address user = msg.sender;
        store.transferIn(user, amount);

        uint256 clpSupply = store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        store.incrementPoolBalance(amount);
        store.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, store.poolBalance());
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

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, store.poolBalance());
    }

}