// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "./IStore.sol";
interface IStoreView {
   

    function BPS_DIVIDER() external view returns (uint256);

    function FUNDING_INTERVAL() external view returns (uint256);

    function MAX_FEE() external view returns (uint256);

    function MAX_KEEPER_FEE_SHARE() external view returns (uint256);

    function MAX_POOL_WITHDRAWAL_FEE() external view returns (uint256);

    function bufferBalance() external view returns (uint256);

    function bufferPayoutPeriod() external view returns (uint256);

    function getBalance(address user) external view returns (uint256);

    function getCLPSupply() external view returns (uint256);

    function getFundingFactor(string memory market) external view returns (uint256);

    function getFundingLastUpdated(string memory market) external view returns (uint256);

    function getFundingTracker(string memory market) external view returns (int256);

    function getLockedMargin(address user) external view returns (uint256);

    function getMarket(string memory market) external view returns (IStore.Market memory _market);

    function getMarketList() external view returns (string[] memory);

    function getOILong(string memory market) external view returns (uint256);

    function getOIShort(string memory market) external view returns (uint256);

    function getOrder(uint256 id) external view returns (IStore.Order memory _order);

    function getOrders() external view returns (IStore.Order[] memory _orders);

    function getPosition(address user, string memory market) external view returns (IStore.Position memory position);

    function getUserOrders(address user) external view returns (IStore.Order[] memory _orders);

    function getUserPoolBalance(address user) external view returns (uint256);

    function getUserPositions(address user) external view returns (IStore.Position[] memory _positions);

    function getUserWithLockedMargin(uint256 i) external view returns (address);

    function getUsersWithLockedMarginLength() external view returns (uint256);

    function keeperFeeShare() external view returns (uint256);

    function marketList(uint256) external view returns (string memory);

    function minimumMarginLevel() external view returns (uint256);

    function poolBalance() external view returns (uint256);

    function poolFeeShare() external view returns (uint256);

    function poolLastPaid() external view returns (uint256);

    function poolWithdrawalFee() external view returns (uint256);
}
