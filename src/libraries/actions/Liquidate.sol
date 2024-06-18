// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Liquidate{
    function validateLiquidate(State storage state, address account, uint amount)external view{
        require(amount > 0, "!amount");
        console.log("execute liquidate");
        
    }

    function executeLiquidate(State storage state, address account, uint amount) external payable{
        console.log("execute liquidate");
        //uint256 balance = state.poolBalance();
        //state.transferIn(account, amount);

        //uint256 clpSupply = state.getCLPSupply();

        //uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
        
        //state.incrementPoolBalance(amount);
        //state.mintCLP(account, clpAmount);

        //emit AddLiquidity(account, amount, clpAmount, state.poolBalance());
    }
}