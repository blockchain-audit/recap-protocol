// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {UpdateGov} from "../libraries/UpdateGov.sol";
import {State} from "../../contracts/CapStorage.sol";
import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

contract UpdateGov{
    function validateUpdateGov(State storage state, address sender, address gov)external {
        if(sender!=state.addresses.gov)
        revert Errors.NOT_ALLOWED();
        if(gov==address(0))
        revert Errors.NULL_INPUT();

    }

    function executeUpdateGov(State storage state, address gov)external{

        address oldGov = gov;
        state.addresses.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }
}