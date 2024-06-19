// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IPool.sol";
import "./interfaces/IStore.sol";

contract Pool is IPool {

    statePool statePool;
    // uint256 public constant BPS_DIVIDER = 10000;

    // address public gov;
    // address public trade;
    // address public treasury;

    // IStore public store;

    // Methods

    modifier onlyTrade() {
        require(msg.sender == statePool.trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == statePool.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        statrPool.gov = _gov;
    }

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = statePool.gov;
        statePool.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _store, address _treasury) external onlyGov {
        statePool.trade = _trade;
        statePool.store = IStore(_store);
        statePool.treasury = _treasury;
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = statePool.store.poolBalance();
        address user = msg.sender;
        statePool.store.transferIn(user, amount);

        uint256 clpSupply = statePool.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        statePool.store.incrementPoolBalance(amount);
        statePool.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amount, clpAmount, statePool.store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = statePool.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = statePool.store.poolBalance();
        uint256 clpSupply = statePool.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        statePool.store.incrementPoolBalance(amountOut);
        statePool.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amountOut, clpAmount, statePool.store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = statePool.store.poolBalance();
        uint256 clpSupply = statePool.store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = statePool.store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * statePool.store.poolWithdrawalFee() / BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        statePool.store.decrementPoolBalance(amountMinusFee);
        statePool.store.burnCLP(user, clpAmount);

        statePool.store.transferOut(user, amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, statePool.store.poolBalance());
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external onlyTrade {
        statePool.store.incrementBufferBalance(amount);
        statePool.store.decrementBalance(user, amount);

        uint256 lastPaid = statePool.store.poolLastPaid();
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            statePool.store.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = statePool.store.bufferBalance();
            uint256 bufferPayoutPeriod = statePool.store.bufferPayoutPeriod();

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            statePool.store.incrementPoolBalance(amountToSendPool);
            statePool.store.decrementBufferBalance(amountToSendPool);
            statePool.store.setPoolLastPaid(_now);
        }

        emit PoolPayIn(user, market, amount, amountToSendPool, statePool.store.poolBalance(), statePool.store.bufferBalance());
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {
        if (amount == 0) return;

        uint256 bufferBalance = statePool.store.bufferBalance();

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = statePool.store.poolBalance();
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            statePool.store.decrementBufferBalance(bufferBalance);
            statePool.store.decrementPoolBalance(diffToPayFromPool);
        } else {
            statePool.store.decrementBufferBalance(amount);
        }

        statePool.store.incrementBalance(user, amount);

        emit PoolPayOut(user, market, amount, statePool.store.poolBalance(), statePool.store.bufferBalance());
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external onlyTrade {
        if (fee == 0) return;

        uint256 poolFee = fee * statePool.store.poolFeeShare() / BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        statePool.store.incrementPoolBalance(poolFee);
        statePool.store.transferOut(treasury, treasuryFee);

        emit FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }
}
