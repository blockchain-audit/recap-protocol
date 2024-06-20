// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "../interfaces/IChainlink.sol";
import "../interfaces/IStore.sol";
import "../interfaces/IPool.sol";
import "../interfaces/ITrade.sol";



struct stateTrade {

    // Contracts
    address  gov;
    IChainlink  chainlink;
    IPool  pool;
    IStore  store;

}


   


