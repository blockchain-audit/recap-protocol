// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "../interfaces/IPool.sol";
import {AddLiquidityThroughUniswap} from "../libraries/actions/AddLiquidityThroughUniswap.sol";

import {AddLiquidity} from "../libraries/actions/AddLiquidity.sol";

contract Pool is CapStorage, IPool{
    using AddLiquidityThroughUniswap for State;
    using AddLiquidity for State;

    function addLiquidity(uint256 amount) external {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }
    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
        state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }




    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external{}

    function creditTraderLoss(address user, string memory market, uint256 amount) external{}

    function debitTraderProfit(address user, string memory market, uint256 amount) external{}

    function link(address _trade, address _store, address _treasury) external{}

    function removeLiquidity(uint256 amount) external{}

    function updateGov(address _gov) external{}
} 