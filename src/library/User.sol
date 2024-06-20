// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RecapStorage} from "../state.sol";
import "../state.sol";

library User {
    function getUserPoolBalance(State storage state, address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(state.contractAddr.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(state.contractAddr.clp).balanceOf(user) * state.store.poolBalance / clpSupply;
    }

    function incrementPoolBalance(State storage state, uint256 amount) external {
        state.store.poolBalance += amount;
    }

    function decrementBalance(State storage state, address user, uint256 amount) external {
        require(amount <= state.store.balances[user], "!balance");
        state.store.balances[user] -= amount;
    }

    function decrementPoolBalance(State storage state, uint256 amount) external {
        state.store.poolBalance -= amount;
    }
}
