//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

struct Pool {
    uint256  BPS_DIVIDER   ;
    address  gov;
    address  trade;
    address  treasury;
    IStore  store;
}