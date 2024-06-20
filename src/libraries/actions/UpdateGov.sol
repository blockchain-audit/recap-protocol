// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";
import {Pool} from "../Pool.sol";


import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

library CreditFee {

    using CLPToken for State;
    using Pool for State;

    function validateUpdateGov(State storage state, address _gov) external view {
        if (msg.sender != state.contracts.gov) {
            revert Errors.NOT_ALLOWED();
        }

        if (_gov == address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

    function validateUpdateGov(State storage state, address _gov) external {

        address oldGov = state.contracts.gov;
        state.contracts.gov = _gov;

        emit Events.GovernanceUpdated(oldGov, _gov);
    }
}