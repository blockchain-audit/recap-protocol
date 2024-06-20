// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {State} from "../../Storage.sol";
import "../modifier.sol";

library Link {
    function link(State storage state, address _trade, address _store, address _treasury) external onlyGov {
        state.pool.trade = _trade;
        state.pool.store = IStore(_store);
        state.pool.treasury = _treasury;
    }
}
