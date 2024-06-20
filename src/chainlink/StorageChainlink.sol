// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


error SequencerDown();
error GracePeriodNotOver();

struct StateChainlink{
    // -- Variables -- //

    AggregatorV3Interface  sequencerUptimeFeed;
}

contract StorageChainlink {
    StateChainlink stateChainlink;
}