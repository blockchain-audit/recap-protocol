//SPDX-License-Identifier:MIT
pragma solidity 0.8.19;

interface IChainlink {
    function getPrice(address feed) external view returns(uint256);
}