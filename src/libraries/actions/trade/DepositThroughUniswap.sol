// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";

import {User} from "../../User.sol";
import {SwapMethods} from "../../SwapMethods.sol";

import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library DepositThroughUniswap {

    using User for State;
    using SwapMethods for State;

    function validateDepositThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint24 poolFee) external view {
        if (poolFee == 0) {
            revert Errors.NULL_INPUT();
        }
        if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeDepositThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external {

        address user = msg.sender;

        // executes swap, tokens will be deposited in the store contract
        uint256 amountOut = state.swapExactInputSingle(amountIn, amountOutMin, tokenIn, poolFee);

        state.incrementBalance(user, amountOut);

        emit Events.Deposit(user, amountOut);
    }
}