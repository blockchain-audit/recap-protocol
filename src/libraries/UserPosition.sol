// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "forge-std/console.sol";
import { State, PositionData } from "../contracts/CapStorage.sol";
import { Position } from "../contracts/CapStorage.sol";

library UserPosition {

    function getUserPositions(State storage state, address user) external view returns (Position[] memory _positions) {
        EnumerableSet.Bytes32Set storage userPositions = state.positionData.positionKeysForUser[user];
        uint256 length = EnumerableSet.length(userPositions);
        _positions = new Position[](length);

        for (uint256 i = 0; i < length; i++) {
            bytes32 positionKey = EnumerableSet.at(userPositions, i);
            _positions[i] = state.positionData.positions[positionKey];
        }

        return _positions;
    }
}
