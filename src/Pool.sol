// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IPool.sol";
// import "src/libraries/modifier.sol";
import {Modifier} from "./libraries/modifier.sol";
// import {State} from "@src/PoolStorage.sol";
// import "@src/PoolStorage.sol";
import {State} from "./Storage.sol";

contract Pool is IPool {
    int256 public constant BPS_DIVIDER = 10000;

    // Methods

    constructor(address _gov) {
        //change
        State.gov = _gov;
    }

    // function updateGov(address _gov) external onlyGov {
    //     require(_gov != address(0), "!address");

    //     address oldGov = gov;
    //     gov = _gov;

    //     emit GovernanceUpdated(oldGov, _gov);
    // }

    // function link(address _trade, address _store, address _treasury) external onlyGov {
    //     trade = _trade;
    //     store = IStore(_store);
    //     treasury = _treasury;
    // }

    // function addLiquidity(uint256 amount) external {
    //     require(amount > 0, "!amount");
    //     uint256 balance = store.poolBalance();
    //     address user = msg.sender;
    //     store.transferIn(user, amount);

    //     uint256 clpSupply = store.getCLPSupply();

    //     uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

    //     store.incrementPoolBalance(amount);
    //     store.mintCLP(user, clpAmount);

    //     emit AddLiquidity(user, amount, clpAmount, store.poolBalance());
    // }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = State.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = State.store.poolBalance();
        uint256 clpSupply = State.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        State.store.incrementPoolBalance(amountOut);
        State.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amountOut, clpAmount, State.store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = State.store.poolBalance();
        uint256 clpSupply = State.store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = State.store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * State.store.poolWithdrawalFee() / BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        State.store.decrementPoolBalance(amountMinusFee);
        State.store.burnCLP(user, clpAmount);

        State.store.transferOut(user, amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, State.store.poolBalance());
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external Modifier.onlyTrade {
        State.store.incrementBufferBalance(amount);
        State.store.decrementBalance(user, amount);

        uint256 lastPaid = State.store.poolLastPaid();
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            State.store.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = State.store.bufferBalance();
            uint256 bufferPayoutPeriod = State.store.bufferPayoutPeriod();

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            State.store.incrementPoolBalance(amountToSendPool);
            State.store.decrementBufferBalance(amountToSendPool);
            State.store.setPoolLastPaid(_now);
        }

        emit PoolPayIn(user, market, amount, amountToSendPool, State.store.poolBalance(), State.store.bufferBalance());
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external Modifier.onlyTrade {
        if (amount == 0) return;

        uint256 bufferBalance = State.store.bufferBalance();

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = State.store.poolBalance();
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            State.store.decrementBufferBalance(bufferBalance);
            State.store.decrementPoolBalance(diffToPayFromPool);
        } else {
            State.store.decrementBufferBalance(amount);
        }

        State.store.incrementBalance(user, amount);

        emit PoolPayOut(user, market, amount, State.store.poolBalance(), State.store.bufferBalance());
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external Modifier.onlyTrade {
        if (fee == 0) return;

        uint256 poolFee = fee * State.store.poolFeeShare() / BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        State.store.incrementPoolBalance(poolFee);
        State.store.transferOut( State.pool.treasury, treasuryFee);

        emit FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
        );
    }
}
