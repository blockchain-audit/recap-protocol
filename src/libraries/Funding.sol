// function setFundingLastUpdated(string calldata market, uint256 timestamp) external onlyContract {
//         fundingLastUpdated[market] = timestamp;
//     }

//     function updateFundingTracker(string calldata market, int256 fundingIncrement) external onlyContract {
//         fundingTrackers[market] += fundingIncrement;
//     }

//     function getFundingLastUpdated(string calldata market) external view returns (uint256) {
//         return fundingLastUpdated[market];
//     }

//     function getFundingFactor(string calldata market) external view returns (uint256) {
//         return markets[market].fundingFactor;
//     }

//     function getFundingTracker(string calldata market) external view returns (int256) {
//         return fundingTrackers[market];
//     }