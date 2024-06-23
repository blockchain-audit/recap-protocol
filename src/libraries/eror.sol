// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Error {
    function sequencerDown() internal pure {
        revert SequencerDown();
    }

    function gracePeriodNotOver() internal pure {
        revert GracePeriodNotOver();
    }

    error SequencerDown();
    error GracePeriodNotOver();
}
