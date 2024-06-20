 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;



library Modifier{
 
 modifier onlyTrade() {
        require(msg.sender == trade, "!trade");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == gov, "!governance");
        _;
    }

    modifier onlyContract() {
        require(msg.sender == trade || msg.sender == pool, "!contract");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == gov, "!governance");
        _;
    }

     modifier onlyGov() {
        require(msg.sender == gov, "!governance");
        _;
    }
}