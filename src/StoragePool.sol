// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./interfaces/IStore.sol";


struct Pool {
    address gov;
    address trade;
    address treasury; 
}

struct PoolState {
    Pool pool;
    IStore store;
}
contract PoolStorage {
    PoolState internal poolState;
}