// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {State} from "../../contracts/CapStorage.sol";
import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

contract UpdateGov{
    function validateUpdateGov(State storage state, address sender, address gov)internal {
        if(sender!=state.addresses.gov)
        revert Errors.NOT_ALLOWED();
        if(gov==address(0))
        revert Errors.NULL_INPUT();

    }

    function executeUpdateGov(State storage state, address gov)internal{

        address oldGov = gov;
        state.addresses.gov = state.addresses.gov;

        emit Events.GovernanceUpdated(oldGov, state.addresses.gov);
    }
}