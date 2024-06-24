
pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "interfaces/ITrade.sol";
import {Deposit} from "libraries/tradeActions/Deposit.sol";
import {DepositThroughUniswap} from "libraries/tradeActions/DepositThroughUniswap.sol";
contract Trade is CapStorage{
    using Deposit for State;
    using Deposit for uint256;

    using DepositThroughUniswap for State;


    function deposit(uint256 amount) external{
        amount.validateDeposit();
        state.executeDeposit(amount);
    }

    function depositThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external payable{
            state.validateDepositThroughUniswap(tokenIn,amountIn,poolFee);
            state.executeDepositThroughUniswap(tokenIn,amountIn,amountOutMin,poolFee);
        } 

    
}
