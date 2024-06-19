// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {Liquidity} from "../libraries/actions/Liquidity.sol";

contract Pool is CapStorage{

    using Liquidity for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }

    function removeLiquidity(uint256 amount) public payable {
        state.validateRemoveLiquidity(amount);
        state.executeRemoveLiquidity(amount);
    }
} 