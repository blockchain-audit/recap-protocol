// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {AddLiquidity} from "../libraries/actions/Pool/AddLiquidity.sol";
import {AddLiquidityThroughUniswap} from "../libraries/actions/Pool/addLiquidityThroughUniswap.sol";
import {RemoveLiquidity} from "../libraries/actions/Pool/RemoveLiquidity.sol";
import {CreditTraderLoss} from "../libraries/actions/Pool/CreditTraderLoss.sol";
import {DebitTraderProfit} from "../libraries/actions/Pool/DebitTraderProfit.sol";
import {CreditFee} from "../libraries/actions/Pool/CreditFee.sol";

contract Pool is CapStorage{

    using AddLiquidity for State;
    using AddLiquidityThroughUniswap for State;
    using RemoveLiquidity for State;
    using CreditTraderLoss for State;
    using DebitTraderProfit for State;
    using CreditFee for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)public payable{
        state.validateAddLiquidityThroughUniswap( tokenIn,  amountIn,  amountOutMin,  poolFee);
        state.executeAddLiquidityThroughUniswap( tokenIn,  amountIn,  amountOutMin,  poolFee);
    }

    function removeLiquidity(uint256 amount)public {
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external{
        state.validateCreditTraderLoss();
        state.executeCreditTraderLoss(user, market, amount);
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external{
        state.validateDebitTraderProfit(amount);
        state.executeDebitTraderProfit(user,market,  amount);
    }   

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external{
        state.validateCreditFee();
        state.executeCreditFee(user,market,fee, isLiquidation);
    }
} 
