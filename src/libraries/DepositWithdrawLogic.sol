pragma solidity ^0.8.24;

import {CLPMethods} from "./CLPMethods.sol";
import {UserBalance} from "./UserBalance.sol";
import {State} from "src/CapStorage.sol";
import {UniswapMethods} from "./UniswapMethods.sol";

import {Events} from "./Events.sol";
import {Errors} from "./Errors.sol";

library DepositWithdrawLogic {

    using CLPMethods for State;
    using UserBalance for State;


    function validateDeposit(State storage state, uint256 amount) external {
        if (amount == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeDeposit(State storage state, uint256 amount) external {
        state.transferIn(amount);
        state.incrementBalance(msg.sender, amount);
        emit Events.Deposit(msg.sender, amount);
    } 


    // function validateDepositThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external
    // {
    //     if (poolFee == 0) {
    //         revert Errors.NULL_INPUT();
    //     }
    //     if (msg.value == 0 || amountIn == 0 && tokenIn == address(0)) {
    //         revert Errors.NULL_INPUT();
    //     }
    // }  

    // function executeDepositThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external
    // {
    //     address user = msg.sender;

    //     // executes swap, tokens will be deposited in the store contract
    //     uint256 amountOut = state.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

    //     store.incrementBalance(msg.sender, amountOut);

    //     emit Events.Deposit(msg.sender, amountOut);
    // } 
}