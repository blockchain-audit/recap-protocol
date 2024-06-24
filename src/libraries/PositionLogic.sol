// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {Position,Market,State} from "../contracts/CapStorage.sol";

import {Errors} from "./Errors.sol";

import {Funding} from "./Funding.sol";
import {Market} from "./Market.sol";
import {PositionLogic} from "./PositionLogic.sol";
import {Constants} from "./Constants.sol";

import "../interfaces/ICLP.sol";

library PositionLogic {
    using Funding for State;
    using Market for State;
    using PositionLogic for State;
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

        int256 currentFundingTracker = state.getFundingTracker(market);
        fundingFee = int256(size) * (currentFundingTracker - fundingTracker) / (int256(Constants.BPS_DIVIDER) * int256(Constants.UNIT)); // funding tracker is in UNIT * bps

        if (isLong) {
            pnl -= fundingFee; // positive = longs pay, negative = longs receive
        } else {
            pnl += fundingFee; // positive = shorts receive, negative = shorts pay
        }

        return (pnl, fundingFee);
    }

    function getUpl(address user) public view returns (int256 upl) {
        Position[] memory positions = state.getUserPositions(user);
        for (uint256 j = 0; j < positions.length; j++) {
            Position memory position = positions[j];
            Market memory market = state.getMarket(position.market);

            uint256 chainlinkPrice = chainlink.getPrice(market.feed);
            if (chainlinkPrice == 0) continue;

            (int256 pnl,) = _getPnL(
                position.market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker
            );

            upl += pnl;
        }

        return upl;
    }

    function getUserPositions(State storage state,address user) external view returns (Position[] memory _positions) {
        uint256 length = state.positionData.positionKeysForUser[user].length();
        _positions = new Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] = positions[state.positionData.positionKeysForUser[user].at(i)];
        }
        return _positions;
    }
}