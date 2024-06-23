pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "./../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import {Events} from "./Events.sol";
library Margin {

// function lockMargin(address user, uint256 amount) external onlyContract {
//         lockedMargins[user] += amount;
//         usersWithLockedMargin.add(user);
//     }

//     function unlockMargin(address user, uint256 amount) external onlyContract {
//         if (amount > lockedMargins[user]) {
//             lockedMargins[user] = 0;
//         } else {
//             lockedMargins[user] -= amount;
//         }
//         if (lockedMargins[user] == 0) {
//             usersWithLockedMargin.remove(user);
//         }
//     }

    function getLockedMargin(address user) external view returns (uint256) {
        return state.userBalances.lockedMargins[user];
    }

    // function getUsersWithLockedMarginLength() external view returns (uint256) {
    //     return usersWithLockedMargin.length();
    // }

    // function getUserWithLockedMargin(uint256 i) external view returns (address) {
    //     return usersWithLockedMargin.at(i);
    // }
    
    }