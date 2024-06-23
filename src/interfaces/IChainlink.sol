// SPDX-License-Identifier: BUSL-1.1
<<<<<<< HEAD

pragma solidity ^0.8.24;

=======
pragma solidity ^0.8.24;
>>>>>>> 97389c2686c0464212163418f9fbabb59f70850f

interface IChainlink {
    function getPrice(address feed) external view returns (uint256);
}
