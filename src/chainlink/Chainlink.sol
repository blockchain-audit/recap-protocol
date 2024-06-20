// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


import "./ViewFuncChainlink.sol";

contract Chainlink is ViewFuncChainlink{

    // -- Errors -- //

    error SequencerDown();
    error GracePeriodNotOver();

    /**
     * For a list of available sequencer proxy addresses, see:
     * https://docs.chain.link/docs/l2-sequencer-flag/#available-networks
     */

    // -- Constructor -- //

    constructor(address sequencer) {
        stateChainlink.sequencerUptimeFeed = AggregatorV3Interface(sequencer);
    }

    
}
