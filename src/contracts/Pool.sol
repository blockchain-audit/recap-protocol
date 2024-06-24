// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
<<<<<<< HEAD:src/Pool.sol
import "./interfaces/IPool.sol";
import {Liquidity} from "src/libraries/Liquidity.sol";
import {CreditTraderLoss} from "src/libraries/CreditTraderLoss.sol";
import {CreditFee} from "src/libraries/CreditFee.sol";
import {DebitTraderProfit} from "./libraries/DebitTraderProfit.sol";
=======
import "../interfaces/IPool.sol";
import {Liquidity} from "../libraries/poolActions/Liquidity.sol";
import {CreditTraderLoss} from "../libraries/poolActions/CreditTraderLoss.sol";
import {CreditFee} from "../libraries/poolActions/CreditFee.sol";
>>>>>>> 1d7c77b5762a399ac1609af858a2e6d250ed33e0:src/contracts/Pool.sol

contract Pool is IPool, CapStorage {

    using Liquidity for State;
    using Liquidity for uint256;
    using CreditTraderLoss for State;
    using CreditFee for State;
<<<<<<< HEAD:src/Pool.sol
    using DebitTraderProfit for State;
=======
    // using DebitTraderProfit for State;
>>>>>>> 1d7c77b5762a399ac1609af858a2e6d250ed33e0:src/contracts/Pool.sol

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
<<<<<<< HEAD:src/Pool.sol
        state.validateDebitTraderProfit(user, amount);
        state.executeDebitTraderProfit(user, market, amount);        
=======
        // state.validateDebitTraderProfit(user, amount);
        // state.executeDebitTraderProfit(user, market, amount);        
>>>>>>> 1d7c77b5762a399ac1609af858a2e6d250ed33e0:src/contracts/Pool.sol
    }

    function link(address _trade, address _store, address _treasury) external {}

    function updateGov(address _gov) external {}
} 