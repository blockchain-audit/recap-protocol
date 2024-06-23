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

        if(msg.value == 0 || amountIn < 0 && tokenIn == address(0))
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
        if(balance < 0 && clpSupply < 0){
          revert  Error.Empty();
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

    

    

    

    
    
}