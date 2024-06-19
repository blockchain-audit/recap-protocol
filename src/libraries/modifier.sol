// SPDX-License-Identifier: MIT
pragma solidity <= 0.8.19;

import {State} from "../Storage.sol";

library Modifier {
    modifier onlyGov(address from) {
        require(from == state.gov, "!governance");
        _;
    }

    modifier onlyTrade() {
        require(from == state.trade, "!trade");
        _;
    }
}
