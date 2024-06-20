// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Errors} from "./Errors.sol";

import {Events} from "./Events.sol";
import "./PoolLibrary.sol";

import "../state.sol";
import "./Buffer.sol";
import "./User.sol";
import "./Transfer.sol";

library Trader {
    //Valiedation function
    using Buffer for State;
    using User for State;
    using PoolLibrary for State;
    using Transfer for State;
    function vailedAddressTrader(State storage state) external {
        if (msg.sender == state.contractAddr.trade) {
            revert Errors.NOT_TRADE_ADDRESS();
        }
    }
  function validateDebitTraderProfit(State storage state, uint256 amount) external view {
        uint256 bufferBalance = state.store.bufferBalance;
        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.store.poolBalance;
            if (diffToPayFromPool < poolBalance) {
                revert Errors.POOL_BALANCE();
            }
        }
    }
    //Function
    function creditTraderLoss(State storage state, address user, string memory market, uint256 amount) external {
        state.incrementBufferBalance(amount);
        state.decrementBalance(user, amount);

        uint256 lastPaid = state.store.poolLastPaid;
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            state.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = state.store.bufferBalance;
            uint256 bufferPayoutPeriod = state.store.bufferPayoutPeriod;

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            state.incrementPoolBalance(amountToSendPool);
            state.decrementBufferBalance(amountToSendPool);
            state.setPoolLastPaid(_now);
        }

        emit Events.PoolPayIn(
            user, market, amount, amountToSendPool, state.store.poolBalance, state.store.bufferBalance
        );
    }
  
    function debitTraderProfit(State storage state, address user, string memory market, uint256 amount) external {
        if (amount == 0) return;

        uint256 bufferBalance = state.store.bufferBalance;

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.store.poolBalance;
            state.decrementBufferBalance(bufferBalance);
            state.decrementPoolBalance(diffToPayFromPool);
        } else {
            state.decrementBufferBalance(amount);
        }

        state.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.store.poolBalance, state.store.bufferBalance);
    }

    function creditFee(State storage state,address user, string memory market, uint256 fee, bool isLiquidation) external {
        if (fee == 0) return;

        uint256 poolFee = fee *state.store.poolFeeShare / state.remainingData.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state.incrementPoolBalance(poolFee);
        state.transferOut(state.pool.treasury, treasuryFee);

        emit Events.FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
        );
    }
}
