// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "src/contracts/CapStorage.sol";
import {CLPToken} from "./CLPtoken.sol";
import {Pool} from "./Pool.sol";
import {UniswapMethods} from "./UniswapMethods.sol";
import {Errors} from "./Errors.sol";
import {Math} from "./Math.sol";
import {Events} from "./Events.sol";

library Liquidity {

    using CLPToken for State;
    using Pool for State;
    using UniswapMethods for State;
    using Math for State;
    using Math for uint256;

    
    function validateAddLiquidity(State storage state, uint256 amount) external view {
         if(amount == 0) {
            revert Errors.NULL_INPUT();
         }
     }

    function executeAddLiquidity(State storage state, uint256 amount) external {
        address user = msg.sender;
        state.transferIn(amount);

        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = state.calculateCLPAmount(amount, clpSupply, balance);

        state.incrementPoolBalance(amount);

        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, state.balances.poolBalance);
    }
    function validateAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint24 poolFee) external view {
        if (poolFee > 0) {
            revert Errors.NULL_INPUT();
        }
        if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
            revert Errors.NULL_INPUT();
        }
        if (address(state.contractAddresses.swapRouter) == address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

    function executeAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external {
        address user = msg.sender;

        uint256 amountOut = state.swapExactInputSingle(amountIn, amountOutMin, tokenIn, poolFee);
        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = state.calculateCLPAmount(amountOut, clpSupply, balance);

        state.incrementPoolBalance(amountOut);
        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.balances.poolBalance);
    }

      function validateremoveLiquidity(State storage  state, uint256 amount) external {
        require(amount > 0, "!amount");
    }

    //   function validateremoveLiquidity(State storage state, uint256 amount, address user) external {
    //     uint256 balance = state.balances.poolBalance;
    //     uint256 clpSupply = state.getCLPSupply();
    //     require(balance > 0 && clpSupply > 0, "!empty");

    //     uint256 userBalance = state.getUserPoolBalance(user);
    //     if (amount > userBalance) amount = userBalance;

    //     uint256 feeAmount = amount.calculateFeeAmount(store.poolWithdrawalFee());
    //     uint256 amountMinusFee = amount.calculateAmountMinusFee(feeAmount);

    //     uint256 clpAmount = amountMinusFee.calculateCLPAmount(clpSupply, balance);

    //     store.decrementPoolBalance(amountMinusFee);
    //     store.burnCLP(user, clpAmount);
    //     store.transferOut(user, amountMinusFee);

    //     emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, store.poolBalance());
    // }
}