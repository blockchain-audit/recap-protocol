// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "./interfaces/IPool.sol";
import "./interfaces/IStore.sol";
import "./Math.sol"; // Importing the Math library

uint256 public constant BPS_DIVIDER = 10000;
uint256 public constant MAX_FEE = 500; // in bps = 5%
uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

contract Pool is IPool {
    using Math for uint256;

    address public gov;
    address public trade;
    address public treasury;

    IStore public store;

    // Methods

    modifier onlyTrade() {
        require(msg.sender == trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == gov, "!governance");
        _;
    }

    constructor(address _gov) {
        gov = _gov;
    }

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = gov;
        gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _store, address _treasury) external onlyGov {
        trade = _trade;
        store = IStore(_store);
        treasury = _treasury;
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");
        uint256 balance = store.poolBalance();
        address user = msg.sender;
        store.transferIn(user, amount);

        uint256 clpSupply = store.getCLPSupply();
        uint256 clpAmount = amount.calculateCLPAmount(clpSupply, balance);

        store.incrementPoolBalance(amount);
        store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amount, clpAmount, store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        require(poolFee > 0, "!poolFee");
        require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = store.poolBalance();
        uint256 clpSupply = store.getCLPSupply();
        uint256 clpAmount = amountOut.calculateCLPAmount(clpSupply, balance);

        store.incrementPoolBalance(amountOut);
        store.mintCLP(user, clpAmount);

        emit AddLiquidity(user, amountOut, clpAmount, store.poolBalance());
    }

    function removeLiquidity(uint256 amount) external {
        require(amount > 0, "!amount");

        address user = msg.sender;
        uint256 balance = store.poolBalance();
        uint256 clpSupply = store.getCLPSupply();
        require(balance > 0 && clpSupply > 0, "!empty");

        uint256 userBalance = store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount.calculateFeeAmount(store.poolWithdrawalFee());
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee.calculateCLPAmount(clpSupply, balance);

        store.decrementPoolBalance(amountMinusFee);
        store.burnCLP(user, clpAmount);

        store.transferOut(user, amountMinusFee);

        emit RemoveLiquidity(user, amount, feeAmount, clpAmount, store.poolBalance());
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external onlyTrade {
        store.incrementBufferBalance(amount);
        store.decrementBalance(user, amount);

        uint256 lastPaid = store.poolLastPaid();
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            store.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = store.bufferBalance();
            uint256 bufferPayoutPeriod = store.bufferPayoutPeriod();

            amountToSendPool = Math.calculateAmountToSendPool(bufferBalance, _now - lastPaid, bufferPayoutPeriod);

            store.incrementPoolBalance(amountToSendPool);
            store.decrementBufferBalance(amountToSendPool);
            store.setPoolLastPaid(_now);
        }

        emit PoolPayIn(user, market, amount, amountToSendPool, store.poolBalance(), store.bufferBalance());
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {
        if (amount == 0) return;

        uint256 bufferBalance = store.bufferBalance();

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = store.poolBalance();
            require(diffToPayFromPool < poolBalance, "!pool-balance");
            store.decrementBufferBalance(bufferBalance);
            store.decrementPoolBalance(diffToPayFromPool);
        } else {
            store.decrementBufferBalance(amount);
        }

        store.incrementBalance(user, amount);

        emit PoolPayOut(user, market, amount, store.poolBalance(), store.bufferBalance());
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external onlyTrade {
        if (fee == 0) return;

        uint256 poolFee = Math.calculatePoolFee(fee, store.poolFeeShare());
        uint256 treasuryFee = fee - poolFee;

        store.incrementPoolBalance(poolFee);
        store.transferOut(treasury, treasuryFee);

        emit FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
        );
    }
}