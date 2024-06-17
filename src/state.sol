
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;














struct Pool{
    uint256 public constant BPS_DIVIDER = 10000;
    address public gov;
    address public trade;
    address public treasury;
    IStore public store;
}
struct State {
    // FeeConfig feeConfig;
    // RiskConfig riskConfig;
    // Oracle oracle;
    // // the protocol data (cannot be updated)
    Pool pool;
}

abstract contract SizeStorage {
    State internal state;
}