// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {State} from "../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import "../interfaces/ICLP.sol";

library Funding {

       function getFundingTracker(State storage state,string calldata market) external view returns (int256) {
        return state.fundingData.fundingTrackers[market];
    }
}