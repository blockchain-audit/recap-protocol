//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "../interfaces/IStore.sol";



struct statePool {

    uint256  BPS_DIVIDER ;
    address  gov;
    address  trade;
    address  treasury;
    IStore  store;
}





