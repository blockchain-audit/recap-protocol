pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {UniswapMethods} from "../UniswapMethods.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {UserActions} from "../UserActions.sol";

import {Events} from "../Events.sol";

library DepositThroughUniswap {
    using CLPToken for State;
    using UserActions for State;
    using UniswapMethods for State;
    
    function validateDepositThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external {
        if(poolFee == 0){
            revert Errors.NULL_INPUT();
        }
        if(msg.value == 0 || amountIn == 0 && tokenIn == address(0)){
            revert Errors.NULL_INPUT();
        }
    }
    function executeDepositThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)external {

        address user = msg.sender;

        uint256 amountOut = state.swapExactInputSingle(user, amountIn, amountOutMin, tokenIn, poolFee);

        state.incrementBalance(msg.sender, amountOut);

        emit Events.Deposit(msg.sender, amountOut);
    }
    
    }

