// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../interfaces/ICLP.sol";

import {State} from "../../contracts/CapStorage.sol";

import {Errors} from "../Errors.sol";

import {Events} from "../Events.sol";


library CLPToken {

    using SafeERC20 for IERC20;

    function mintCLP(State storage state, uint256 amount) external  {
        ICLP(state.clp).mint(msg.sender, amount);
    }

    function burnCLP(State storage state, uint256 amount) external  {
        ICLP(state.clp).burn(msg.sender, amount);
    }

    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.clp).totalSupply();
    }
  
    function transferIn(State storage state, uint256 amount) external {
        IERC20(state.currency).safeTransferFrom(msg.sender, address(this), amount);
    }

    function transferOut(State storage state, uint256 amount) external {
        IERC20(state.currency).safeTransfer(msg.sender, amount);
    }
}