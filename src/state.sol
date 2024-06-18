//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./interfaces/IChainlink .sol";
import "./interfaces/IStore.sol";
contract A{
    uint public s;

}

struct pool {
    uint256  BPS_DIVIDER;
    address  gov;
    address  trade;
    address  treasury;
    IStore  store;
}

struct CLP{
     address store;
}

struct chinLink{
    uint256  UNIT ;
    uint256 GRACE_PERIOD_TIME  ;

}
