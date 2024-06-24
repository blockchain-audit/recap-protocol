// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {LoanStatus} from "@src/libraries/LoanLibrary.sol";

/// @title Errors
/// @custom:security-contact security@size.credit
/// @author Size (https://size.credit/)
library Errors {
    error SequencerDown();
    error GracePeriodNotOver();
    error Store_address();
    error Amount_is_Zero();
    error Poolfee_isnt_zero();
    error No_input();
    error Not_empty();
    error Not_pool_balance();
    error Not_max_fee();
    error Not_trade();
}