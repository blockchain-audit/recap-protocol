// function _getPnL(
//         string memory market,
//         bool isLong,
//         uint256 price,
//         uint256 positionPrice,
//         uint256 size,
//         int256 fundingTracker
//     ) internal view returns (int256 pnl, int256 fundingFee) {
//         if (price == 0 || positionPrice == 0 || size == 0) return (0, 0);

//         if (isLong) {
//             pnl = int256(size) * (int256(price) - int256(positionPrice)) / int256(positionPrice);
//         } else {
//             pnl = int256(size) * (int256(positionPrice) - int256(price)) / int256(positionPrice);
//         }

//         int256 currentFundingTracker = store.getFundingTracker(market);
//         fundingFee = int256(size) * (currentFundingTracker - fundingTracker) / (int256(BPS_DIVIDER) * int256(UNIT)); // funding tracker is in UNIT * bps

//         if (isLong) {
//             pnl -= fundingFee; // positive = longs pay, negative = longs receive
//         } else {
//             pnl += fundingFee; // positive = shorts receive, negative = shorts pay
//         }

//         return (pnl, fundingFee);
//     }
