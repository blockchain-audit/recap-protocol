// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "forge-std/console.sol";

import {State} from "../contracts/CapStorage.sol";
import {Position} from "../contracts/CapStorage.sol";

library UserPosition {

    function getUserPositions(State storage state, address user) external view returns (Position[] memory _positions) {
    //     uint256 length = state.positionData.positionKeysForUser[user].length();
    //     _positions = new Position[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         _positions[i] = state.positionData.positions[state.positionData.positionKeysForUser[user].at(i)];
    //     }
        return _positions;
    }
}