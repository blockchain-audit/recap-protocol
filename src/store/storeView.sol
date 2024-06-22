// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;


import {StateStore} from "./storeStorage.sol";

abstract contract viewStore is storeStorage {
    
//Function view

    function getCLPSupply() external view returns (uint256) {
        return IERC20(clp).totalSupply();
    }

    function getBalance(address user) external view returns (uint256) {
        return balances[user];
    }

    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(clp).balanceOf(user) * poolBalance / clpSupply;
    }

    function getLockedMargin(address user) external view returns (uint256) {
        return lockedMargins[user];
    }

    function getUsersWithLockedMarginLength() external view returns (uint256) {
        return usersWithLockedMargin.length();
    }

    function getUserWithLockedMargin(uint256 i) external view returns (address) {
        return usersWithLockedMargin.at(i);
    }

        function getOILong(string calldata market) external view returns (uint256) {
        return OILong[market];
    }

    function getOIShort(string calldata market) external view returns (uint256) {
        return OIShort[market];
    }

    function getOrder(uint256 id) external view returns (Order memory _order) {
        return orders[id];
    }

    function getOrders() external view returns (Order[] memory _orders) {
        uint256 length = orderIds.length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = orders[orderIds.at(i)];
        }
        return _orders;
    }

    function getUserOrders(address user) external view returns (Order[] memory _orders) {
        uint256 length = userOrderIds[user].length();
        _orders = new Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = orders[userOrderIds[user].at(i)];
        }
        return _orders;
    }

    function getUserPositions(address user) external view returns (Position[] memory _positions) {
        uint256 length = positionKeysForUser[user].length();
        _positions = new Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] = positions[positionKeysForUser[user].at(i)];
        }
        return _positions;
    }

    function getPosition(address user, string calldata market) public view returns (Position memory position) {
        bytes32 key = _getPositionKey(user, market);
        return positions[key];
    }

    function getMarket(string calldata market) external view returns (Market memory _market) {
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