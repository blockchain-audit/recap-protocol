pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {UniswapMethods} from "../UniswapMethods.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {UserActions} from "../UserActions.sol";

import {Events} from "../Events.sol";

library Deposit {
    using CLPToken for State;
    using UserActions for State;
    function validateDeposit(State storage state,uint256 amount) external{
        if (amount == 0 ){
            revert Errors.NULL_AMOUNT();
        }
    }
    function executeDeposit(State storage state, uint256 amount) external{
        state.transferIn(msg.sender, amount);
        state.incrementBalance(msg.sender, amount);
        emit Events.Deposit(msg.sender, amount);
    }
}

