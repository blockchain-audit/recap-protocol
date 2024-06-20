// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../state.sol";

import {RecapStorage} from "../state.sol";
// import"../../src/interfaces/IPool.sol";
import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

library PoolLibrary {
    modifier onlyGov(State storage state) {
        require(msg.sender == state.remainingData.gov, "!governance");
        _;
    }
    // Methods
    function initialization(State storage state, address _gov) external {
        state.remainingData.gov = _gov;
        state.remainingData.BPS_DIVIDER = 1000;
        state.store.poolWithdrawalFee = 10;
        state.store.bufferPayoutPeriod = 7 days;
        state.store.poolFeeShare = 5000;
    }

    function valiedGov(State storage state, address _gov) external view {
        if (_gov != address(0)) {
            revert Errors.NULL_ADDRESS();
        }
    }

    function updateGov(State storage state, address _gov) external onlyGov(state) {
        address oldGov = state.remainingData.gov;
        state.remainingData.gov = _gov;
        emit Events.GovernanceUpdated(oldGov, _gov);
    }

    function setPoolLastPaid(State storage state, uint256 timestamp) external {
        state.store.poolLastPaid = timestamp;
    }
}
