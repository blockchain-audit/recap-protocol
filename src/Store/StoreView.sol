// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "lib/v3-periphery/contracts/interfaces/IQuoter.sol";
import "../interfaces/IStore.sol";
import {Store, StoreState, StorageStore} from "./StorageStore.sol";

contract StoreView is StorageStore {

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    function getCLPSupply() external view returns (uint256) {
        return IERC20(storeState.clp).totalSupply();
    }

    function getBalance(address user) external view returns (uint256) {
        return storeState.balances[user];
    }

    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(storeState.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(storeState.clp).balanceOf(user) * storeState.poolBalance / clpSupply;
    }

    function getLockedMargin(address user) external view returns (uint256) {
        return storeState.lockedMargins[user];
    }

    function getUsersWithLockedMarginLength() external view returns (uint256) {
        return storeState.usersWithLockedMargin.length();
    }

    function getUserWithLockedMargin(uint256 i) external view returns (address) {
        return storeState.usersWithLockedMargin.at(i);
    }

    function getOILong(string calldata market) external view returns (uint256) {
        return storeState.OILong[market];
    }

    function getOIShort(string calldata market) external view returns (uint256) {
        return storeState.OIShort[market];
    }

    function getOrder(uint256 id) external view returns (IStore.Order memory _order) {
        return storeState.orders[id];
    }

    function getOrders() external view returns (IStore.Order[] memory _orders) {
        uint256 length = storeState.orderIds.length();
        _orders = new storeState.Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = orders[orderIds.at(i)];
        }
        return _orders;
    }

    function getUserOrders(address user) external view returns (IStore.Order[] memory _orders) {
        uint256 length = userOrderIds[user].length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = orders[userOrderIds[user].at(i)];
        }
        return _orders;
    }

    function getUserPositions(address user) external view returns (IStore.Position[] memory _positions) {
        uint256 length = positionKeysForUser[user].length();
        _positions = new Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] = positions[positionKeysForUser[user].at(i)];
        }
        return _positions;
    }

    function getPosition(address user, string calldata market) public view returns (IStore.Position memory position) {
        bytes32 key = _getPositionKey(user, market);
        return positions[key];
    }

    function getMarket(string calldata market) external view returns (IStore.Market memory _market) {
        return markets[market];
    }

    function getMarketList() external view returns (string[] memory) {
        return marketList;
    }

    function getFundingLastUpdated(string calldata market) external view returns (uint256) {
        return fundingLastUpdated[market];
    }

    function getFundingFactor(string calldata market) external view returns (uint256) {
        return markets[market].fundingFactor;
    }

    function getFundingTracker(string calldata market) external view returns (int256) {
        return fundingTrackers[market];
    }
}