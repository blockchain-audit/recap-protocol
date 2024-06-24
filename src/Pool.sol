// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "./interfaces/IPool.sol";
import {Liquidity} from "src/libraries/Liquidity.sol";
import {CreditTraderLoss} from "src/libraries/CreditTraderLoss.sol";
import {CreditFee} from "src/libraries/CreditFee.sol";
import {DebitTraderProfit} from "./libraries/debitTraderProfit.sol";

contract Pool is IPool, CapStorage {

    using Liquidity for State;
    using Liquidity for uint256;
    using CreditTraderLoss for State;
    using CreditFee for State;
    using DebitTraderProfit for State;

    function addLiquidity(uint256 amount) public {
        amount.validateAddLiquidity();
        state.executeAddLiquidity(amount);
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) public payable {
            state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, poolFee);
            state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);     
    }

    function removeLiquidity(uint256 amount) public {
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);       
    }
    function creditFee(string memory market, uint256 fee, bool isLiquidation) external{
        state.validateCreditFee(fee);
        state.executeCreditFee(market, fee, isLiquidation);
    }

    function creditTraderLoss(string memory market, uint256 amount) external {
        state.validateCreditTraderLoss();
        state.executeCreditTraderLoss(market, amount);
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external {
        state.validateDebitTraderProfit(user, amount);
        state.executeDebitTraderProfit(user, market, amount);        
    }

    function link(address _trade, address _store, address _treasury) external {}

    function updateGov(address _gov) external {}
} 