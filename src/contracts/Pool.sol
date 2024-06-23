// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "../interfaces/IPool.sol";

import {AddLiquidity} from "../libraries/actions/pool/AddLiquidity.sol";
import {AddLiquidityThroughUniswap} from "../libraries/actions/pool/AddLiquidityThroughUniswap.sol";
import {RemoveLiquidity} from "../libraries/actions/pool/RemoveLiquidity.sol";
import {CreditTraderLoss} from "../libraries/actions/pool/CreditTraderLoss.sol";
import {DebitTraderProfit} from "../libraries/actions/pool/DebitTraderProfit.sol";
import {CreditFee} from "../libraries/actions/pool/CreditFee.sol";

contract Pool is CapStorage, IPool {

    using AddLiquidity for State;
    using AddLiquidityThroughUniswap for State;
    using RemoveLiquidity for State;
    using CreditTraderLoss for State;
    using DebitTraderProfit for State;
    using CreditFee for State;

    function addLiquidity(uint256 amount) public {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    // msg.value - to send eth 
    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) public payable {
        state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, poolFee);
        state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }

    function removeLiquidity(uint256 amount) public {
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) public {
        state.validateCreditTraderLoss();
        state.executeCreditTraderLoss(user, market, amount);
    }

    function debitTraderProfit(address user,string memory market, uint256 amount) public {
        state.validateDebitTraderProfit(amount);
        state.executeDebitTraderProfit(user, market, amount);
    }

    function creditFee(address user,string memory market, uint256 fee, bool isLiquidation) public {
        state.validateCreditFee();
        state.executeCreditFee(user, market, fee, isLiquidation);
    }

    // function link(address _pool) public {
    //     state.contractAddresses.pool = _pool;
    //     // address gov;
    //     // address currency;
    //     // address clp;
    //     // address swapRouter;
    //     // address quoter;
    //     // address weth;
    //     // address trade;
    //     // address pool;
    //     // address treasury;
    // }
} 