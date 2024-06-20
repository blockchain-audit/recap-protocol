pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import {Events} from "../Events.sol";
library UserActions {
   function incrementBalance(State storage state,address user, uint256 amount) external  {
        state.balances[user] += amount;
    }

    function decrementBalance(State storage state, address user, uint256 amount) external  {
        if (amount <= state.balances[user]){
            state.balances[user] -= amount;
        }
        else {
            revert Errors.AMOUNT_EXCEEDS_BALANCE();
        }
        
    }

    function getBalance(State storage state, address user) external view returns (uint256) {
        return state.balances[user];
    }

}

