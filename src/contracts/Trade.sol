// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {State, CapStorage} from "./CapStorage.sol";

import {Deposit} from "../libraries/actions/trade/Deposit.sol";
import {DepositThroughUniswap} from "../libraries/actions/trade/DepositThroughUniswap.sol";
import {Withdraw} from "../libraries/actions/trade/Withdraw.sol";

contract Trade is CapStorage {

    using Deposit for State;
    using DepositThroughUniswap for State;
    using Withdraw for State;

    function deposit(address user, uint256 amount) public {
        state.validateDeposit(amount);
        state.executeDeposit(user, amount);
    }

    function depositThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) public {
        state.validateDepositThroughUniswap(tokenIn, amountIn, poolFee);
        state.executeDepositThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }

    function withdraw(uint256 amount) public {
        state.validateWithdraw(amount);
        state.executeWithdraw(amount);
    }
} 