// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../../interfaces/IStore.sol";

library State {
    struct pool {
        address treasury;
        IStore store;
    }
}
