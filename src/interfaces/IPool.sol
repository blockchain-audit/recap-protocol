// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

interface IPool {
    function addLiquidity(uint256 amount) external;

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable;

    function creditFee(string memory market, uint256 fee, bool isLiquidation) external;

    function creditTraderLoss(string memory market, uint256 amount) external; // we delete address user

    function debitTraderProfit(address user, string memory market, uint256 amount) external;

    function link(address _trade, address _store, address _treasury) external;

    function removeLiquidity(uint256 amount) external;

    function updateGov(address _gov) external;
}