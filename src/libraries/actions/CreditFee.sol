// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";
import {Pool} from "../Pool.sol";


import {Errors} from "../Errors.sol";
import {Events} from "../Events.sol";

library CreditFee {

    using CLPToken for State;
    using Pool for State;

    function validateCreditFee(State storage state) external view {
        if (msg.sender != state.contracts.trade) {
            revert Errors.NOT_TRADER();
        }
    }

    function executeCreditFee(State storage state, address user, string memory market, uint256 fee, bool isLiquidation) external {
        if (fee == 0) return;

        uint256 poolFee = fee * state.variables.poolFeeShare / state.constants.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state.incrementPoolBalance(poolFee);
        state.transferOut(state.treasury, treasuryFee);

        emit Events.FeePaid(
            user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }
}