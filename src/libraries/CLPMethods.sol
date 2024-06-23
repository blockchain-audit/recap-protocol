// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

<<<<<<< HEAD
import {State} from "src/contracts/CapStorage.sol";
=======
import {State} from "src/CapStorage.sol";
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f

import {Errors} from "./Errors.sol";

import "src/interfaces/ICLP.sol";

library CLPMethods{

    using SafeERC20 for IERC20;

    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.contractAddresses.clp).totalSupply();
    }

    function mintCLP(State storage state, uint256 amount) external {
        ICLP(state.contractAddresses.clp).mint(msg.sender, amount);
    }
    function burnCLP(State storage state, uint256 amount) external {
        ICLP(state.contractAddresses.clp).burn(msg.sender, amount);
    }
    function transferIn(State storage state, uint256 amount) external {
        IERC20(state.contractAddresses.currency).safeTransferFrom(msg.sender, state.contractAddresses.pool, amount);
    }

    function transferOut(State storage state, address user, uint256 amount) external {
        IERC20(state.contractAddresses.currency).safeTransfer(user, amount);
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f
