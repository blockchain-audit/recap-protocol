// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Market,State} from "../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import "../interfaces/ICLP.sol";

library Market {
    function getMarket(State storage state,string calldata market) external view returns (Market memory _market) {
        return state.marketData.markets[market];
    }

    function getMarketList(State storage state) external view returns (string[] memory) {
        return state.marketData.marketList;
    }
}