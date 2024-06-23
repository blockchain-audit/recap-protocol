// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.20;


interface IChainlink {
    function getPrice(address feed) external view returns (uint256);
}
