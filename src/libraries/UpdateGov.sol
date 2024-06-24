pragma solidity ^0.8.24;

import {State} from "./../contracts/CapStorage.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

library UpdateGov {
    function validateUpdateGov(State storage state, address _gov) external {
        if (msg.sender != state.contractAddresses.gov) {
            revert Errors.NOT_GOV();
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
