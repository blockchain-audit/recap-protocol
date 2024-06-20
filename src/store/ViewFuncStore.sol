// SPDX-License-Identifier: MIT
pragma solidity >=0.5.11;
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "../interfaces/IStoreView.sol";
import "./StorageStore.sol";
abstract contract ViewFuncStore is StorageStore , IStoreView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    // StorageStore.StateStore public stateStore = Storage.stateStore;
    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(stateStore.clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(stateStore.clp).balanceOf(user) * stateStore.poolBalance / clpSupply;
    }

    function getLockedMargin(address user) external view returns (uint256) {
        return stateStore.lockedMargins[user];
    }

    function getUsersWithLockedMarginLength() external view returns (uint256) {
        return stateStore.usersWithLockedMargin.length();
    }

    function getUserWithLockedMargin(uint256 i) external view returns (address) {
        return stateStore.usersWithLockedMargin.at(i);
    }


    function getOILong(string calldata market) external view returns (uint256) {
        return stateStore.OILong[market];
    }

    function getOIShort(string calldata market) external view returns (uint256) {
        return stateStore.OIShort[market];
    }

     function getOrder(uint256 id) external view returns (IStore.Order memory _order) {
        return stateStore.orders[id];
    }

    function getOrders() external view returns (IStore.Order[] memory _orders) {
        uint256 length = stateStore.orderIds.length();
        _orders = new IStore.Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = stateStore.orders[stateStore.orderIds.at(i)];
        }
        return _orders;
    }

    function getUserOrders(address user) external view returns (IStore.Order[] memory _orders) {
        uint256 length = stateStore.userOrderIds[user].length();
        _orders = new IStore.Order[](length);
        for (uint256 i = 0; i < length; i++) {
            _orders[i] = stateStore.orders[stateStore.userOrderIds[user].at(i)];
        }
        return _orders;
    }

     function getUserPositions(address user) external view returns (IStore.Position[] memory _positions) {
        uint256 length = stateStore.positionKeysForUser[user].length();
        _positions = new IStore.Position[](length);
        for (uint256 i = 0; i < length; i++) {
            _positions[i] = stateStore.positions[stateStore.positionKeysForUser[user].at(i)];
        }
        return _positions;
    }

    function getPosition(address user, string calldata market) public view returns (IStore.Position memory position) {
        bytes32 key = _getPositionKey(user, market);
        return stateStore.positions[key];
    }

    // Markets
    function getMarket(string calldata market) external view returns (IStore.Market memory _market) {
        return stateStore.markets[market];
    }

    function getMarketList() external view returns (string[] memory) {
        return stateStore.marketList;
    }
    
    function getFundingLastUpdated(string calldata market) external view returns (uint256) {
        return stateStore.fundingLastUpdated[market];
    }

    function getFundingFactor(string calldata market) external view returns (uint256) {
        return stateStore.markets[market].fundingFactor;
    }

    function getFundingTracker(string calldata market) external view returns (int256) {
        return stateStore.fundingTrackers[market];
    }

    function getCLPSupply() external view returns (uint256) {
        return IERC20(stateStore.clp).totalSupply();
    }

    function getBalance(address user) external view returns (uint256) {
        return stateStore.balances[user];
    }

        function _getPositionKey(address user, string calldata market) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, market));
    }
}