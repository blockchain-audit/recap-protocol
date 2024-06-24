// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State, Order} from "../contracts/CapStorage.sol";

import {User} from "./User.sol";
import {Functions} from "./actions/trade/Functions.sol";
import {CLPToken} from "./CLPToken.sol";

import {Errors} from "./Errors.sol";
import {Events} from "./Events.sol";

library OrderLibrary {
    function updateOrder(State storage state, Order calldata order) external {
        state.orderData.orders[order.orderId] = order;
    }
}