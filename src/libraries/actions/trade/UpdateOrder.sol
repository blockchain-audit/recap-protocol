// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State, Order, Market, TradeData} from "../../../contracts/CapStorage.sol";

import {User} from "../../User.sol";
import {PositionLogic} from "./PositionLogic.sol";
import {CLPToken} from "../../CLPToken.sol";
import {OrderLibrary} from "../../OrderLibrary.sol";

import {Errors} from "../../Errors.sol";
import {Events} from "../../Events.sol";

library Withdraw {

    using User for State;
    using PositionLogic for State;
    using CLPToken for State;
    using OrderLibrary for State;

    function validateUpdateOrder(State storage state, uint256 orderId, uint256 price) external view {
        Order memory order = state.orderData.orders[orderId];
        if (order.user != msg.sender) {
            revert Errors.NOT_USER();
        }
        if (order.size <= 0) {
            revert Errors.NULL_ORDER();
        }
        if (order.orderType == 0) {
            revert Errors.NULL_MARKET_ORDER();
        }

        Market memory market = state.marketData.markets[order.market];
        TradeData memory trade;
        uint256 chainlinkPrice = trade.chainlink.getPrice(market.feed);
        if (chainlinkPrice <= 0) {
            revert Errors.NULL_CHAINLINK();
        }
    }

    function executeUpdateOrder(State storage state, uint256 orderId, uint256 price) external {
        Order memory order = state.orderData.orders[orderId];

        Market memory market = state.marketData.markets[order.market];
        TradeData memory trade;
        uint256 chainlinkPrice = trade.chainlink.getPrice(market.feed);

        if (
            order.orderType == 1 && order.isLong && chainlinkPrice <= price
                || order.orderType == 1 && !order.isLong && chainlinkPrice >= price
                || order.orderType == 2 && order.isLong && chainlinkPrice >= price
                || order.orderType == 2 && !order.isLong && chainlinkPrice <= price
        ) {
            if (order.orderType == 1) order.orderType = 2;
            else order.orderType = 1;
        }

        order.price = price;
        state.updateOrder(order);
    }
}