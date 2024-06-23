pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {PoolActions} from "../PoolActions.sol";

import {Events} from "../Events.sol";

import {GetUpl} from "./GetUpl.sol";
import {UserActions} from "../UserActions.sol";

library Withdraw {
    using GetUpl for State;
    using UserActions for State;
    using CLPToken for State;

    function validateWithdraw(State storage state, uint256 amount) external {
        address user = msg.sender;
        // if amount to withdraw > balance, set it to balance
        uint256 balance = state.getBalance(user);
        if (amount > balance) amount = balance;

     // equity after withdraw
        int256 upl = state.getUpl(user);
        uint256 lockedMargin = state.getLockedMargin(user);
        int256 equity = int256(balance - amount) + upl; 

     // adjust amount if equity after withdrawing < lockedMargin
        if (equity < int256(lockedMargin)) {
            int256 maxWithdrawableAmount;
            maxWithdrawableAmount = int256(balance) - int256(lockedMargin) + upl;

            if (maxWithdrawableAmount < 0) amount = 0;
            else amount = uint256(maxWithdrawableAmount);
        }
        if (amount == 0){
            revert Errors.NULL_AMOUNT();
        }
        uint256 lockedMargin = state.getLockedMargin(user);
        // this should never trigger, but we keep it in as fail safe
        if(int256(lockedMargin) > int256(balance - amount) + upl){
            revert Errors.INSUFFICIENT_EQUITY();
        }
    }
    function executeWithdraw(State storage state, uint256 amount) external {
            address user = msg.sender;

        // if amount to withdraw > balance, set it to balance
        uint256 balance = store.getBalance(user);
        if (amount > balance) amount = balance;

        // equity after withdraw
        int256 upl = getUpl(user);
        uint256 lockedMargin = store.getLockedMargin(user);
        int256 equity = int256(balance - amount) + upl; 

        // adjust amount if equity after withdrawing < lockedMargin
        if (equity < int256(lockedMargin)) {
            int256 maxWithdrawableAmount;
            maxWithdrawableAmount = int256(balance) - int256(lockedMargin) + upl;

            if (maxWithdrawableAmount < 0) amount = 0;
            else amount = uint256(maxWithdrawableAmount);
        }

        state.decrementBalance(user, amount);
        state.transferOut(msg.sender, amount);
        emit Events.Withdraw(msg.sender, amount);
        
        }

}
