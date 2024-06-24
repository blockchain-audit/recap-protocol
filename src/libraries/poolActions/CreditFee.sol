pragma solidity ^0.8.24;

import {State} from "../../contracts/CapStorage.sol";
import {Events} from "../Events.sol";
import {Errors} from "../Errors.sol";
import {PoolMethods} from "../PoolMethods.sol";
import {CLPMethods} from "../CLPMethods.sol";
import {Constants} from "../Constants.sol";

library CreditFee {
    using PoolMethods for State;
    using CLPMethods for State;

    function validateCreditFee(State storage state, uint256 fee) view external {
        if (msg.sender != state.contractAddresses.trade) {
            revert Errors.NOT_TRADER();
        }

        if (fee == 0) {
            revert Errors.NULL_INPUT();
        }
    }

    function executeCreditFee(State storage state, string memory market, uint256 fee, bool isLiquidation) external {
        address user = msg.sender;

        // if (fee == 0) return;

        uint256 poolFee = fee * state.fees.poolFeeShare / Constants.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state.incrementPoolBalance(poolFee);
        state.transferOut(state.contractAddresses.treasury, treasuryFee);

        emit Events.FeePaid(user, market, fee, poolFee, isLiquidation);
    }
}
