// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "../interfaces/ITrade.sol";
import "../libraries/actions/Trade/Deposit.sol";
import "../libraries/actions/Trade/DepositThroughUniswap.sol";


contract Trade is CapStorage, ITrade{
    using Deposit for State;
    using DepositThroughUniswap for State;
    function deposit( amount) external {
        state.validateDeposit(amount);
        state.executeDeposit(amount);
    }

    function depositThroughUniswap(address tokenIn, uint256 amountIn , uint256 amountOutMin, uint24 poolFee) external payable{
        state.validateDepositThroughUniswap(tokenIn,amountIn,amountOutMin,poolFee);
        state.executeDepositThroughUniswap(tokenIn,amountIn,amountOutMin,poolFee);
    }

    funtion withdraw(uint256 amount) external{
        state.validateWithdraw(amount);
        state.executeWithdraw(amount);
    }

}