// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "../interfaces/IPool.sol";
import {Liquidity} from "src/libraries/Liquidity.sol";

contract Pool is IPool, CapStorage {

    using Liquidity for State;

    function addLiquidity(uint256 amount) public {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) public payable {
            state.validateAddLiquidityThroughUniswap(tokenIn, amountIn, poolFee);
            state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);     
    }

    function removeLiquidity(uint256 amount) public {
        // state.validateRemoveLiquidity(amount);
        // state.executeRemoveLiquidity(amount);       
    }
  function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external{}

    function creditTraderLoss(address user, string memory market, uint256 amount) external{}

    function debitTraderProfit(address user, string memory market, uint256 amount) external{}

    function link(address _trade, address _store, address _treasury) external{}

    function updateGov(address _gov) external{}
} 

