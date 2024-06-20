//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Constant {
    uint256 public constant BPS_DIVIDER = 10000;
    uint256 public constant MAX_FEE = 500; 
    uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; 
    uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; 
    uint256 public constant FUNDING_INTERVAL = 1 hours;
    uint256 public constant UNIT = 10 ** 18;
    uint256 public constant GRACE_PERIOD_TIME = 3600;
}