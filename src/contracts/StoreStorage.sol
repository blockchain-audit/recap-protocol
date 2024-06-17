// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

struct Constant {
    uint256 constant BPS_DIVIDER;
    uint256 constant MAX_FEE;
    uint256 constant MAX_KEEPER_FEE_SHARE;
    uint256 constant MAX_POOL_WITHDRAWAL_FEE;
    uint256 constant FUNDING_INTERVAL;
}


struct Contract {
    address gov;
    address currency;
    address clp;

    address swapRouter;
    address quoter;
    address weth;

    address trade;
    address pool;
}
