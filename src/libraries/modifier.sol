// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//import {State} from "../Storage.sol";
import "../Storage.sol";
library Modifier {
    modifier onlyGov(address from) {
        require(from == State.gov, "!governance");
        _;
    }
    modifier onlyTrade(address from)  {
        require(from ==  State.trade, "!trade");
        _;
    }
}