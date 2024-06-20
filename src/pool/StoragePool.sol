// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../interfaces/IStore.sol";
import "../interfaces/IStoreView.sol";

//storage
struct StatePool {

    address gov;
    address trade;
    address treasury;
    IStoreView storeView;
    IStore store;

}
contract StoragePool{
    StatePool statePool;
}