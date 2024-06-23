// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../../contracts/CapStorage.sol";
import {Constants} from "../../Constants.sol";

import {CLPToken} from "../../CLPToken.sol";
import {Pool} from "../../Pool.sol";


import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library CreditFee {

    using CLPToken for State;
    using Pool for State;

    function validateCreditFee(State storage state) external view {
        if (msg.sender != state.contractAddresses.trade) {
            revert Errors.NOT_ALLOWED();
        }
    }

    function executeCreditFee(State storage state, address user, string memory market, uint256 fee, bool isLiquidation) external {
        if (fee == 0) return;

        uint256 poolFee = fee * state.fees.poolFeeShare / Constants.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state.incrementPoolBalance(poolFee);
        state.transferOut(state.contractAddresses.treasury, treasuryFee);

        emit Events.FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }
}