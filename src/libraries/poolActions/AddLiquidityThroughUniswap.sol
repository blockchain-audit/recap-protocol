pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {UniswapMethods} from "../UniswapMethods.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPMethods} from "../CLPMethods.sol";

import {PoolMethods} from "../PoolMethods.sol";

import {Errors} from "../Errors.sol";

import {Events} from "../Events.sol";

import {Math} from "../Math.sol";

library AddLiquidityThroughUniswap {
    using CLPMethods for State;
    using PoolMethods for State;
    using UniswapMethods for State;
    using Math for State;
    using Math for uint256;

    function validateAddLiquidityThroughUniswap(State storage state, address tokenIn, uint256 amountIn, uint24 poolFee)
        external
        view
    {
        if (poolFee <= 0) {
            revert Errors.NULL_INPUT();
        }
        if (msg.value <= 0 || (amountIn < 0 && tokenIn == address(0))) {
            revert Errors.NULL_INPUT();
        }
        if (address(state.contractAddresses.swapRouter) == address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

    function executeAddLiquidityThroughUniswap(
        State storage state,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMin,
        uint24 poolFee
    ) external {
        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.swapExactInputSingle(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.balances.poolBalance;
        uint256 clpSupply = state.getCLPSupply();
        uint256 clpAmount = amountOut.calculateCLPAmount(clpSupply, balance);
        state.incrementPoolBalance(amountOut);
        state.mintCLP(clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.balances.poolBalance);
    }
}
