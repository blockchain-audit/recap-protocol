// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./StorageChainlink.sol";

contract ViewFuncChainlink is StorageChainlink{

    uint256 constant GRACE_PERIOD_TIME = 3600;
        uint256 constant UNIT = 10 ** 18;

    // StorageChainlink.StateChainlink public stateChainlink = StorageChainlink.stateChainlink;

    function getPrice(address feed) public view returns (uint256) {
        if (feed == address(0)) return 0;

        // if we are not on a L2, skip sequencer check
        if (address(stateChainlink.sequencerUptimeFeed) != address(0)) {
            (
                /*uint80 roundId*/
                ,
                int256 answer,
                uint256 startedAt,
                /*uint256 updatedAt*/
                ,
                /*uint80 answeredInRound*/
            ) = stateChainlink.sequencerUptimeFeed.latestRoundData();

            // Answer == 0: Sequencer is up
            // Answer == 1: Sequencer is down
            bool isSequencerUp = answer == 0;
            if (!isSequencerUp) {
                revert SequencerDown();
            }

            // Make sure the grace period has passed after the sequencer is back up.
            uint256 timeSinceUp = block.timestamp - startedAt;

            if (timeSinceUp <= GRACE_PERIOD_TIME) {
                revert GracePeriodNotOver();
            }
        }

        AggregatorV3Interface priceFeed = AggregatorV3Interface(feed);
        (
            /*uint80 roundID*/
            ,
            int256 price,
            /*uint startedAt*/
            ,
            /*uint timeStamp*/
            ,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        uint8 decimals = priceFeed.decimals();

        // Return 18 decimals standard
        return uint256(price) * UNIT / 10 ** decimals;
    }

}