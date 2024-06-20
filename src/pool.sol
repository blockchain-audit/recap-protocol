// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./libraries/error.sol";
import "./libraries/constants.sol";
import "./interfaces/IPool.sol";
import "./state.sol";
import "./libraries/event.sol";

contract Pool is Storage{
    //IPool, 
    using errors for State;
    using constants for State;
    using events for State;

    modifier onlyGov() {
        require(msg.sender == state.pools.gov, "!governance");
        _;
    }

    modifier onlyTrade() {
        require(msg.sender == state.pools.trade, "!trade");
        _;
    }
    constructor(address _gov) {
        state.pools.gov = _gov;
    }

    function updateGov(address _gov) external onlyGov {
        if(_gov == address(0)){
            revert errors.UnValidAddress();
        } 
        address oldGov = state.pools.gov;
        state.pools.gov = _gov;

        emit events.GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _store, address _treasury) external onlyGov {
        state.pools.trade = _trade;
        state.pools.store = IStore(_store);
        state.pools.treasury = _treasury;
    }

    function addLiquidity(uint256 amount) external {
        if(amount <= 0){
            revert errors.UnvalidAmount();
        }
        
        uint256 balance = state.pools.store.poolBalance();
        address user = msg.sender;
        state.pools.store.transferIn(user, amount);

        uint256 clpSupply = state.pools.store.getCLPSupply();

        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;

        state.pools.store.incrementPoolBalance(amount);
        state.pools.store.mintCLP(user, clpAmount);

        emit events.AddLiquidity(user, amount, clpAmount, state.pools.store.poolBalance());
    }

    function addLiquidityThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee)
        external
        payable
    {
        if(poolFee < 0){
            revert errors.UnValidPoolFee();
        }

        if(msg.value == 0 || amountIn <= 0 && tokenIn == address(0)){
            revert errors.UnValidInput();
        }

        address user = msg.sender;

        // executes swap, tokens will be deposited to store contract
        uint256 amountOut = state.pools.store.swapExactInputSingle{value: msg.value}(user, amountIn, amountOutMin, tokenIn, poolFee);

        // add store supported liquidity
        uint256 balance = state.pools.store.poolBalance();
        uint256 clpSupply = state.pools.store.getCLPSupply();
        uint256 clpAmount = balance == 0 || clpSupply == 0 ? amountOut : amountOut * clpSupply / balance;

        state.pools.store.incrementPoolBalance(amountOut);
        state.pools.store.mintCLP(user, clpAmount);

        emit events.AddLiquidity(user, amountOut, clpAmount, state.pools.store.poolBalance());
    }

    
}
