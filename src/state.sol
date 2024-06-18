// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import 

// struct ContractAddress{
    // address public trade;
    // address public pool;
    // address public clp;
    // address public store;
// }

// struct RemainingData{
//     address public gov;
//     uint256 public constant BPS_DIVIDER = 10000;
// }

struct Chainlink {
    uint  UINT;
}

struct Pool{
    address  treasury;
    // IStore  store;
}
struct State {
    // RemainingData remainingData;
    // Store store;
    // ChainLink chainlink;
    // ContractAddress contractAddr;
    Pool pool;
}
abstract contract RecapStorage {
    State internal state;
}


