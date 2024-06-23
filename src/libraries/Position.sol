// pragma solidity ^0.8.24;

// import "forge-std/console.sol";

// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// import {State} from "./../contracts/CapStorage.sol";

// import {Errors} from "./Errors.sol";

// import {Events} from "./Events.sol";
// library Position {

//     function addOrUpdatePosition(Position calldata position) external onlyContract {
//         bytes32 key = _getPositionKey(position.user, position.market);
//         positions[key] = position;
//         positionKeysForUser[position.user].add(key);
//         positionKeys.add(key);
//     }

//     function removePosition(address user, string calldata market) external onlyContract {
//         bytes32 key = _getPositionKey(user, market);
//         positionKeysForUser[user].remove(key);
//         positionKeys.remove(key);
//         delete positions[key];
//     }

//     function getUserPositions(address user) external view returns (Position[] memory _positions) {
//         uint256 length = state.positionKeysForUser[user].length();
//         _positions = new Position[](length);
//         for (uint256 i = 0; i < length; i++) {
//             _positions[i] = positions[positionKeysForUser[user].at(i)];
//         }
//         return _positions;
//     }

//     function getPosition(address user, string calldata market) public view returns (Position memory position) {
//         bytes32 key = _getPositionKey(user, market);
//         return positions[key];
//     }

//     function _getPositionKey(address user, string calldata market) internal pure returns (bytes32) {
//         return keccak256(abi.encodePacked(user, market));
//     }
// }