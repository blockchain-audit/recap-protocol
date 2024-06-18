// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


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

struct Constant {
    uint256 constant BPS_DIVIDER;
    uint256 constant MAX_FEE;
    uint256 constant MAX_KEEPER_FEE_SHARE;
    uint256 constant MAX_POOL_WITHDRAWAL_FEE;
    uint256 constant FUNDING_INTERVAL;
}