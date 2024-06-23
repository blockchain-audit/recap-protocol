// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LoanStatus} from "@src/libraries/LoanLibrary.sol";

/// @title Errors
/// @custom:security-contact security@size.credit
/// @author Size (https://size.credit/)
library Errors {
    error SequencerDown();
    error GracePeriodNotOver();
}