
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {State} from "@src/SizeStorage.sol";

import"../../src/interfaces/IPool.sol";
library PoolLibarary is IPool {
    using Pool for State
 // Methods
 function initialization(address _gov)public{
    state.remainingData.gov=_gov;
 }

    modifier onlyTrade() {
        require(msg.sender == state.contractAddr.trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == state.remainingData.gov, "!governance");
        _;
    }
    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");
        address oldGov = state.remainingData.gov;
        state.remainingData.gov = _gov;
        emit GovernanceUpdated(oldGov, _gov);
    }
}