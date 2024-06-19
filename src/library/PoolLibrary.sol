
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../state.sol";

import {RecapStorage} from "../state.sol";
// import"../../src/interfaces/IPool.sol";
import {Errors} from "./Errors.sol";

library PoolLibrary  {

    modifier onlyTrade(State storage state) {
        require(msg.sender == state.contractAddr.trade, "!trade");
        _;
    }

    modifier onlyGov(State storage state) {
        require(msg.sender == state.remainingData.gov, "!governance");
        _;
    }
     // Methods
    function initialization(State storage state,address _gov)public{
         state.remainingData.gov=_gov;
    }
    function valiedGov(address _gov)external view{
        if(_gov != address(0)){
            revert Errors.NULL_ADDRESS();
        }
    }
    function updateGov(State storage state,address _gov) external onlyGov(state) {
        address oldGov = state.remainingData.gov;
        state.remainingData.gov = _gov;
        // emit state.pool.store.GovernanceUpdated(oldGov, _gov);
    }
    // function link(address _trade, address _store, address _treasury) external onlyGov {
    //     trade = _trade;
    //     store = IStore(_store);
    //     treasury = _treasury;
    // }
   
    // function removeLiquidity(uint256 amount) external {
    //     require(amount > 0, "!amount");

    //     address user = msg.sender;
    //     uint256 balance = state.pool.store.poolBalance();
    //     uint256 clpSupply = state.pool.store.getCLPSupply();
    //     require(balance > 0 && clpSupply > 0, "!empty");

    //     uint256 userBalance = state.pool.store.getUserPoolBalance(user);
    //     if (amount > userBalance) amount = userBalance;

    //     uint256 feeAmount = amount * state.pool.store.poolWithdrawalFee() / BPS_DIVIDER;
    //     uint256 amountMinusFee = amount - feeAmount;

    //     // CLP amount
    //     uint256 clpAmount = amountMinusFee * clpSupply / balance;

    //     store.decrementPoolBalance(amountMinusFee);
    //     store.burnCLP(user, clpAmount);

    //     store.transferOut(user, amountMinusFee);

    //     emit RemoveLiquidity(user, amount, feeAmount, clpAmount, state.pool.store.poolBalance());
    // }

    // function creditTraderLoss(address user, string memory market, uint256 amount) external onlyTrade {
    //     store.incrementBufferBalance(amount);
    //     store.decrementBalance(user, amount);

    //     uint256 lastPaid = store.poolLastPaid();
    //     uint256 _now = block.timestamp;
    //     uint256 amountToSendPool;

    //     if (lastPaid == 0) {
    //         store.setPoolLastPaid(_now);
    //     } else {
    //         uint256 bufferBalance = store.bufferBalance();
    //         uint256 bufferPayoutPeriod = store.bufferPayoutPeriod();

    //         amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

    //         if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

    //         store.incrementPoolBalance(amountToSendPool);
    //         store.decrementBufferBalance(amountToSendPool);
    //         store.setPoolLastPaid(_now);
    //     }

    //     emit PoolPayIn(user, market, amount, amountToSendPool, store.poolBalance(), store.bufferBalance());
    // }

    // function debitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {
    //     if (amount == 0) return;

    //     uint256 bufferBalance = store.bufferBalance();

    //     if (amount > bufferBalance) {
    //         uint256 diffToPayFromPool = amount - bufferBalance;
    //         uint256 poolBalance = store.poolBalance();
    //         require(diffToPayFromPool < poolBalance, "!pool-balance");
    //         store.decrementBufferBalance(bufferBalance);
    //         store.decrementPoolBalance(diffToPayFromPool);
    //     } else {
    //         store.decrementBufferBalance(amount);
    //     }

    //     store.incrementBalance(user, amount);

    //     emit PoolPayOut(user, market, amount, store.poolBalance(), store.bufferBalance());
    // }

    // function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external onlyTrade {
    //     if (fee == 0) return;

    //     uint256 poolFee = fee * store.poolFeeShare() / BPS_DIVIDER;
    //     uint256 treasuryFee = fee - poolFee;

    //     store.incrementPoolBalance(poolFee);
    //     store.transferOut(treasury, treasuryFee);

    //     emit FeePaid(
    //         user,
    //         market,
    //         fee, // paid by user //
    //         poolFee,
    //         isLiquidation
    //         );
    // }
}

