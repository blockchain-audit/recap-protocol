pragma solidity ^0.8.24;

import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Buffer} from "../Buffer.sol";

import {UserActions} from "../UserActions.sol";

import {State} from "../../contracts/CapStorage.sol";

import {CLPToken} from "../CLPToken.sol";

import {Errors} from "../Errors.sol";

import {PoolActions} from "../PoolActions.sol";

import {Events} from "../Events.sol";


   

library CreditFee{
    
    using PoolActions for State;
    using CLPToken for State;
    using Buffer for State;
    using UserActions for State;
function validateCreditFee(State storage state, address user, string memory market, uint256 fee, bool isLiquidation) external{
    if (fee == 0) return;
}
function executeCreditFee(State storage state,address user, string memory market, uint256 fee, bool isLiquidation) external{
        uint256 poolFee = fee * state.fees.poolFeeShare / state.constants.BPS_DIVIDER;
        uint256 treasuryFee = fee - poolFee;

        state.incrementPoolBalance(poolFee);
        state.transferOut(state.contractAddresses.treasury, treasuryFee);

        emit Events.FeePaid( user,
            market,
            fee, // paid by user //
            poolFee,
            isLiquidation
            );
    }

}

