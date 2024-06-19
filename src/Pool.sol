// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IPool.sol";
import "./interfaces/IStore.sol";
import "./State";
contract Pool is IPool {

    statePool p;

    // uint256 public constant BPS_DIVIDER = 10000;
    // address public gov;
    // address public trade;
    // address public treasury;
    // IStore public store;

    // Methods

    modifier onlyTrade() {
        require(msg.sender == p.trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == p.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        p.gov = _gov;
    }

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = gov;
        p.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _store, address _treasury) external onlyGov {
        p.trade = _trade;
        p.store = IStore(_store);
        p.treasury = _treasury;
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = p.store.poolBalance();
        address user = msg.sender;
        p.store.transferIn(user, amount);

        uint256 clpSupply = p.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        p.store.incrementPoolBalance(amount);
        p.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amount, clpAmount, p.store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = p.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = p.store.poolBalance();
        uint256 clpSupply = p.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        p.store.incrementPoolBalance(amountOut);
        p.store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amountOut, clpAmount, p.store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = p.store.poolBalance();
        uint256 clpSupply = p.store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = p.store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * p.store.poolWithdrawalFee() / p.BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

        p.store.decrementPoolBalance(amountMinusFee);
        p.store.burnCLP(user, clpAmount);

        p.store.transferOut(user, amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, p.store.poolBalance());
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external onlyTrade {
        p.store.incrementBufferBalance(amount);
        p.store.decrementBalance(user, amount);

        uint256 lastPaid = p.store.poolLastPaid();
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            p.store.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = p.store.bufferBalance();
            uint256 bufferPayoutPeriod = p.store.bufferPayoutPeriod();

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            p.store.incrementPoolBalance(amountToSendPool);
            p.store.decrementBufferBalance(amountToSendPool);
            p.store.setPoolLastPaid(_now);
        }

        emit PoolPayIn(user, market, amount, amountToSendPool, p.store.poolBalance(), p.store.bufferBalance());
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {
        if (amount == 0) return;

        uint256 bufferBalance = p.store.bufferBalance();

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = p.store.poolBalance();
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            p.store.decrementBufferBalance(bufferBalance);
            p.store.decrementPoolBalance(diffToPayFromPool);
        } else {
            p.store.decrementBufferBalance(amount);
        }

        p.store.incrementBalance(user, amount);

        emit PoolPayOut(user, market, amount, p.store.poolBalance(), p.store.bufferBalance());
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external onlyTrade {
        if (fee == 0) return;

        uint256 poolFee = fee * p.store.poolFeeShare() / p.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        p.store.incrementPoolBalance(poolFee);
        p.store.transferOut(p.treasury, treasuryFee);

        emit FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }
}
