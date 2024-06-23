// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {State} from "../../Storage.sol";
import "../event.sol";
import {Modifier} from "../modifier.sol";



library Update {
    function updateGov(State storage state, address _gov, address from) external Modifier.onlyGov(from) {
        require(_gov != address(0), "!address");

        address oldGov = State.gov;
        State.gov = _gov;

        // emit GovernanceUpdated(oldGov, _gov);
    }
}
