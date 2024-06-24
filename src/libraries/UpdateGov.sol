// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../contracts/CapStorage.sol";

import {CLPToken} from "./CLPToken.sol";
import {Pool} from "./Pool.sol";


import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

library UpdateGov {

    using CLPToken for State;
    using Pool for State;

    function validateUpdateGov(State storage state, address _gov) external view {
        if (msg.sender != state.contractAddresses.gov) {
            revert Errors.NOT_ALLOWED();
        }

        if (_gov == address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

    function executeUpdateGov(State storage state, address _gov) external {

        address oldGov = state.contractAddresses.gov;
        state.contractAddresses.gov = _gov;

        emit Events.GovernanceUpdated(oldGov, _gov);
    }
}