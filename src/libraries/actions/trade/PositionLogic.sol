// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import { State } from "../../../contracts/CapStorage.sol";
import { TradeData, Position, Market } from "../../../contracts/CapStorage.sol";

import "../../../interfaces/IChainlink.sol";

import { Constants } from "../../Constants.sol";

import { UserPosition } from "../../UserPosition.sol";

import { Errors } from "../../Errors.sol";
import { Events } from "../../Events.sol";

library PositionLogic {

    using UserPosition for State;
    
    function getUpl(State storage state, address user) public view returns (int256 upl) {
        Position[] memory positions = state.getUserPositions(user);
        for (uint256 j = 0; j < positions.length; j++) {
            Position memory position = positions[j];
            Market memory market = state.marketData.markets[position.market];
            TradeData memory trade;
            uint256 chainlinkPrice = trade.chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;

            (int256 pnl,) = _getPnL(
                state, position.market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker
            );

            upl += pnl;
        }

        return upl;
    }

    function _getPnL(
        State storage state,
        string memory market,
        bool isLong,
        uint256 price,
        uint256 positionPrice,
        uint256 size,
        int256 fundingTracker
    ) internal view returns (int256 pnl, int256 fundingFee) {
        if (price == 0 || positionPrice == 0 || size == 0) return (0, 0);

        if (isLong) {
            pnl = int256(size) * (int256(price) - int256(positionPrice)) / int256(positionPrice);
        } else {
            pnl = int256(size) * (int256(positionPrice) - int256(price)) / int256(positionPrice);
        }

        int256 currentFundingTracker = state.fundingData.fundingTrackers[market];
        fundingFee = int256(size) * (currentFundingTracker - fundingTracker) / (int256(Constants.BPS_DIVIDER) * int256(Constants.UNIT)); // funding tracker is in UNIT * bps

        if (isLong) {
            pnl -= fundingFee; // positive = longs pay, negative = longs receive
        } else {
            pnl += fundingFee; // positive = shorts receive, negative = shorts pay
        }

        return (pnl, fundingFee);
    }
}