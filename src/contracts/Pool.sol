// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "./CapStorage.sol";

import {AddLiquidity} from "../libraries/actions/AddLiquidity.sol";

contract Pool is CapStorage{

    using AddLiquidity for State;

    function addLiquidity(uint256 amount) public payable {
        state.validateAddLiquidity(amount);
        state.executeAddLiquidity(amount);
    }
} 