pragma solidity ^0.8.24;

interface IChainlink {
    function getPrice(address feed) external view returns (uint256);
}
