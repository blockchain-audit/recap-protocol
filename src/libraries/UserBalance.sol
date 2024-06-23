pragma solidity ^0.8.24;

<<<<<<< HEAD
import {State} from "src/contracts/CapStorage.sol";
=======
import {State} from "src/CapStorage.sol";
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f

library UserBalance {
    function incrementBalance( State storage state, address user, uint256 amount) external {
        state.userBalances.balances[user] += amount;
    }

    function decrementBalance(State storage state, address user, uint256 amount) external {
        require(amount <= state.userBalances.balances[user], "!balance");
        state.userBalances.balances[user] -= amount;
    }

    function getBalance(State storage state, address user) external view returns (uint256) {
        return  state.userBalances.balances[user];
    }
}