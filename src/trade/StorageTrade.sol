// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;
import "../interfaces/IChainlink.sol";
import "../interfaces/IStore.sol";
import "../interfaces/IStoreView.sol";
import "../interfaces/IPool.sol";
struct StateTrade{

    // Contracts
    address gov;
    IChainlink chainlink;
    IPool pool;
    IStore store;
    IStoreView storeView;
}

contract StorageTrade{
    StateTrade stateTrade;
}