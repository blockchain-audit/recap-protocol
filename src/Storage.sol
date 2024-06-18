pragma solidity ^0.8.19;
import "./interfaces/IPool.sol";
import "./interfaces/IStore.sol";

 uint256 public constant BPS_DIVIDER = 10000;

    address public gov;
    address public trade;
    address public treasury;

    IStore public store;
contract CapStorage {

}