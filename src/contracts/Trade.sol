// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import {State, CapStorage} from "./CapStorage.sol";

import {Deposit} from "../libraries/actions/trade/Deposit.sol";

contract Trade is CapStorage {

    using Deposit for State;

    function deposit(address user, uint256 amount) public {
        state.validateDeposit(amount);
        state.executeDeposit(user, amount);
    }
} 