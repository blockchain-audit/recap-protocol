// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;
import {CapStorage} from "./capStorage";
import {Liquidate} from "./libraries/actions/Liquidate.sol";
contract Pool is IPool, CapStorage {
    using Liquidate for State;

    function addLiquidity(uint256 amount) external {
        state.validateLiquidate(msg.sender,amount);
        state.executeLiquidate(msg.sender,amount);
    }
}
