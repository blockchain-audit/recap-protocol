// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "../interfaces/IPool.sol";
import {AddLiquidityThroughUniswap} from "../libraries/poolActions/AddLiquidityThroughUniswap.sol";

import {AddLiquidity} from "../libraries/poolActions/AddLiquidity.sol";

import {RemoveLiquidity} from "../libraries/poolActions/RemoveLiquidity.sol";
import {CreditTraderLoss} from "../libraries/poolActions/CreditTraderLoss.sol";
import {DebitTraderProfit} from "../libraries/poolActions/DebitTraderProfit.sol";
import {CreditFee} from "../libraries/poolActions/CreditFee.sol";

contract Pool is CapStorage, IPool{
    using AddLiquidityThroughUniswap for State;
    using AddLiquidity for State;
    using RemoveLiquidity for State;
    using CreditTraderLoss for State;
    using DebitTraderProfit for State;
    using CreditFee for State;

    function link(address _trade, address _store, address _treasury) external{}

    function updateGov(address _gov) external{}


    function addLiquidity(uint256 amount) external {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }
    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, poolFee);
        state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }
    
    function removeLiquidity(uint256 amount) external{
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);
    }
    
    function creditTraderLoss(address user, string memory market, uint256 amount) external{
        state.validateCreditTraderLoss(user, market, amount);
        state.executeCreditTraderLoss(user, market, amount);
        
    }
    function debitTraderProfit(address user, string memory market, uint256 amount) external{
        state.validateDebitTraderProfit(user, market, amount);
        state.executeDebitTraderProfit(user, market, amount);
    }




    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external{
        state.validateCreditFee(user, market, fee, isLiquidation);
        state.executeCreditFee(user, market, fee, isLiquidation);
        
    }

    

    


} 