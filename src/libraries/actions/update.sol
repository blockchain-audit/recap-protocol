// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {State} from "../../Storage.sol";
import {Modifier} from "../modifier.sol";
// import {Event} from "../Event.sol";

library Update {
    function updateGov(State storage state, address _gov, address from) external Modifier.onlyGov(from) {
        require(_gov != address(0), "!address");

        address oldGov = state.gov;
        state.gov = _gov;

        // emit Event.GovernanceUpdated(oldGov, _gov);
    }
}
