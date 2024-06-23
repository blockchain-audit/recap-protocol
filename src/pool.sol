//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "./libraries/modifieres.sol";
import "./libraries/error.sol";
import "./libraries/constent.sol";
import "./libraries/events.sol";
import "./interfaces/IPool.sol";
import "./state.sol";

abstract contract Pool is IPool, Storage{
    using Error for State;
    using Constant for State;
    using Events for State;
    // using Modifier for State;
    
    modifier onlyTrade() {
        require(msg.sender == state.pools.trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == state.pools.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        state.pools.gov = _gov;
    }

    function updateGov(address _gov) external onlyGov {
        if(_gov == address(0))
            revert Error.NotValidAddress();
        address oldGov = state.pools.gov;
        state.pools.gov = _gov;

        emit Events.GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _store, address _treasury) external onlyGov {
        state.pools.trade = _trade;
        state.pools.store = IStore(_store);
        state.pools.treasury = _treasury;
    }

     function addLiquidity(uint256 amount) external {
        // require(amount > 0, "!amount");
        if(amount < 0)
            revert Error.UnValidAmount();

        uint256 balance = state.pools.store.poolBalance();
        address user = msg.sender;
        state.pools.store.transferIn(user, amount);

        uint256 clpSupply = state.pools.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.pools.store.incrementPoolBalance(amount);
        state.pools.store.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amount, clpAmount, state.pools.store.poolBalance());
    }

        function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        // require(poolFee > 0, "!poolFee");
        if(poolFee < 0)
            revert  Error.UnVolidpoolFee();

        if(msg.value == 0 && amountIn < 0 || tokenIn == address(0))
            revert Error.UnValidInput();
        // require(msg.value != 0 || amountIn > 0 && tokenIn != address(0), "!input");

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.pools.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.pools.store.poolBalance();
        uint256 clpSupply = state.pools.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.pools.store.incrementPoolBalance(amountOut);
        state.pools.store.mintCLP(user, clpAmount);

        emit Events.AddLiquidity(user, amountOut, clpAmount, state.pools.store.poolBalance());
    }

     function removeLiquidity(uint256 amount) external {
        // require(amount > 0, "!amount");
        if(amount < 0){
            revert Error.UnValidAmount();
        }


        address user = msg.sender;
        uint256 balance = state.pools.store.poolBalance();
        uint256 clpSupply = state.pools.store.getCLPSupply();
        // require(balance > 0 && clpSupply > 0, "!empty");
        if(balance < 0 || clpSupply < 0){
          revert  Error.CantBeEmpty();
        }
        uint256 userBalance = state.pools.store.getUserPoolBalance(user);
        if (amount > userBalance) amount = userBalance;

        uint256 feeAmount = amount * state.pools.store.poolWithdrawalFee() / Constant.BPS_DIVIDER;
        uint256 amountMinusFee = amount - feeAmount;

        // CLP amount
        uint256 clpAmount = amountMinusFee * clpSupply / balance;

       
        state.pools.store.decrementPoolBalance(amountMinusFee);
        state.pools.store.burnCLP(user, clpAmount);

        state.pools.store.transferOut(user, amountMinusFee);

        emit Events.RemoveLiquidity(user, amount, feeAmount, clpAmount, state.pools.store.poolBalance());
    }

    function creditTraderLoss(address user, string memory market, uint256 amount) external onlyTrade {
        state.pools.store.incrementBufferBalance(amount);
        state.pools.store.decrementBalance(user, amount);

        uint256 lastPaid = state.pools.store.poolLastPaid();
        uint256 _now = block.timestamp;
        uint256 amountToSendPool;

        if (lastPaid == 0) {
            state.pools.store.setPoolLastPaid(_now);
        } else {
            uint256 bufferBalance = state.pools.store.bufferBalance();
            uint256 bufferPayoutPeriod = state.pools.store.bufferPayoutPeriod();

            amountToSendPool = bufferBalance * (block.timestamp - lastPaid) / bufferPayoutPeriod;

            if (amountToSendPool > bufferBalance) amountToSendPool = bufferBalance;

            state.pools.store.incrementPoolBalance(amountToSendPool);
            state.pools.store.decrementBufferBalance(amountToSendPool);
            state.pools.store.setPoolLastPaid(_now);
        }

        emit Events.PoolPayIn(user, market, amount, amountToSendPool, state.pools.store.poolBalance(), state.pools.store.bufferBalance());
    }

    function debitTraderProfit(address user, string memory market, uint256 amount) external onlyTrade {
        if (amount == 0) return;

        uint256 bufferBalance = state.pools.store.bufferBalance();

        if (amount > bufferBalance) {
            uint256 diffToPayFromPool = amount - bufferBalance;
            uint256 poolBalance = state.pools.store.poolBalance();
            // require(diffToPayFromPool < poolBalance, "!pool-balance");
            if(diffToPayFromPool >= poolBalance)
               revert Error.NotPoolBalance();

            state.pools.store.decrementBufferBalance(bufferBalance);
            state.pools.store.decrementPoolBalance(diffToPayFromPool);
        } else {
            state.pools.store.decrementBufferBalance(amount);
        }

        state.pools.store.incrementBalance(user, amount);

        emit Events.PoolPayOut(user, market, amount, state.pools.store.poolBalance(), state.pools.store.bufferBalance());
    }

    function creditFee(address user, string memory market, uint256 fee, bool isLiquidation) external onlyTrade {
        if (fee == 0) return;

        uint256 poolFee = fee * state.pools.store.poolFeeShare() / Constant.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state.pools.store.incrementPoolBalance(poolFee);
        state.pools.store.transferOut(state.pools.treasury, treasuryFee);

        emit Events.FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }




    

    

    

    
    
}