// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {RecapStorage, State} from "../src/state.sol";
import {Liquidate} from "./library/Liquidate.sol";
import {PoolLibrary} from "./library/PoolLibrary.sol";
import {Trader} from "./library/Trader.sol";

contract MainPool is RecapStorage {
    using PoolLibrary for State;
    using Liquidate for State;
    using Trader for State;

    constructor(address _gov) {
        state.initialization(_gov);
    }

    function updateGov(address newGov) public {
        state.valiedGov(newGov);
        state.updateGov(newGov);
    }

    function addLiquidity(uint256 amount) public {
        state.valiedAmountLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    function addLiquidityToUniswap(
        address user,
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenIn,
        uint24 poolFee
    ) public payable {
        state.valiedUniswap(tokenIn, amountIn, poolFee);
        state.valiedUniswapDetails(tokenIn, amountIn);
        state.executeAddLiquidityThroughUniswap(tokenIn, amountIn, amountOutMin, poolFee);
    }

    function removeLiquidity(uint256 amount) public {
        state.validateRemoveLiquidity(amount);
        state.executeremoveLiquidity(amount);
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) public {
        state.vailedAddressTrader();
        state.creditTraderLoss(user, market, amount);
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) public {
        state.vailedAddressTrader();
        state.validateDebitTraderProfit(amount);
        state.debitTraderProfit(user, market, amount);
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) public {
        state.creditFee(user, market, fee, isLiquidation);
    }
}
