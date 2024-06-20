// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "./IStore.sol";

interface ITradeView {

    function getAccruedFunding(string memory market, uint256 intervals) external view returns (int256);

    function getExecutableOrderIds() external view returns (uint256[] memory orderIdsToExecute);

    function getLiquidatableUsers() external view returns (address[] memory usersToLiquidate);

    function getMarketsWithPrices() external view returns (IStore.Market[] memory _markets, uint256[] memory _prices);

    function getUpl(address user) external view returns (int256 upl);

    function getUserPositionsWithUpls(address user)
        external
        view
        returns (IStore.Position[] memory _positions, int256[] memory _upls);
}
