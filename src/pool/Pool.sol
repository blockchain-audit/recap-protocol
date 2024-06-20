// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IPool.sol";
import "../interfaces/IStore.sol";

import {statePool} from "src/pool/poolStorage.sol";
contract Pool is IPool {

    statePool state_pool;

    // uint256 public constant BPS_DIVIDER = 10000;
    // address public gov;
    // address public trade;
    // address public treasury;
    // IStore public store;

    // Methods

    modifier onlyTrade() {
        require(msg.sender == state_pool.trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == state_pool.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        state_pool.gov = _gov;
    }

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = state_pool.gov;
        state_pool.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _store, address _treasury) external onlyGov {
        state_pool.trade = _trade;
        state_pool.store = IStore(_store);
        state_pool.treasury = _treasury;
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = state_pool.store.poolBalance();
        address user = msg.sender;
        state_pool.store.transferIn(user, amount);

        uint256 clpSupply = state_pool.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state_pool.store.incrementPoolBalance(amount);
        state_pool.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amount, clpAmount, state_pool.store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state_pool.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state_pool.store.poolBalance();
        uint256 clpSupply = state_pool.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state_pool.store.incrementPoolBalance(amountOut);
        state_pool.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amountOut, clpAmount, state_pool.store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = state_pool.store.poolBalance();
        uint256 clpSupply = state_pool.store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = state_pool.store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * state_pool.store.poolWithdrawalFee() / state_pool.BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        state_pool.store.decrementPoolBalance(amountMinusFee);
        state_pool.store.burnCLP(user, clpAmount);

        state_pool.store.transferOut(user, amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, state_pool.store.poolBalance());
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external onlyTrade {
        state_pool.store.incrementBufferBalance(amount);
        state_pool.store.decrementBalance(user, amount);

        uint256 lastPaid = state_pool.store.poolLastPaid();
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            state_pool.store.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = state_pool.store.bufferBalance();
            uint256 bufferPayoutPeriod = state_pool.store.bufferPayoutPeriod();

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            state_pool.store.incrementPoolBalance(amountToSendPool);
            state_pool.store.decrementBufferBalance(amountToSendPool);
            state_pool.store.setPoolLastPaid(_now);
        }

        emit PoolPayIn(user, market, amount, amountToSendPool, state_pool.store.poolBalance(), state_pool.store.bufferBalance());
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {
        if (amount == 0) return;

        uint256 bufferBalance = state_pool.store.bufferBalance();

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state_pool.store.poolBalance();
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            state_pool.store.decrementBufferBalance(bufferBalance);
            state_pool.store.decrementPoolBalance(diffToPayFromPool);
        } else {
            state_pool.store.decrementBufferBalance(amount);
        }

        state_pool.store.incrementBalance(user, amount);

        emit PoolPayOut(user, market, amount, state_pool.store.poolBalance(), state_pool.store.bufferBalance());
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external onlyTrade {
        if (fee == 0) return;

        uint256 poolFee = fee * state_pool.store.poolFeeShare() / state_pool.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state_pool.store.incrementPoolBalance(poolFee);
        state_pool.store.transferOut(state_pool.treasury, treasuryFee);

        emit FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }
}
