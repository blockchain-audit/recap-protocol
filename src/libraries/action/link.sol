// SPDX-License-Identifier: MIT
pragma solidity <=0.8.25;

import {State} from "../../Storage.sol";

import {Modifier} from "../modifier.sol";

import "../../interfaces/IStore.sol";

library Link {
    function link(State storage state, address _trade, address _store, address _treasury, address from) external Modifier.onlyGov(from) {
        state.pool.trade = _trade;
        state.pool.store = IStore(_store);
        state.pool.treasury = _treasury;
    }
}