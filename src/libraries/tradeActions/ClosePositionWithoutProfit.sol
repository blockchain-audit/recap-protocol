    // function closePositionWithoutProfit(string memory _market) external {
    //     address user = msg.sender;

    //     IStore.Position memory position = store.getPosition(user, _market);
    //     require(position.size > 0, "!position");

    //     IStore.Market memory market = store.getMarket(_market);

    //     store.decrementOI(_market, position.size, position.isLong);

    //     _updateFundingTracker(_market);

    //     uint256 chainlinkPrice = chainlink.getPrice(market.feed);
    //     require(chainlinkPrice > 0, "!price");

    //     // P/L

    //     (int256 pnl,) =
    //         _getPnL(_market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker);

    //     // Only profitable positions can be closed this way
    //     require(pnl >= 0, "pnl < 0");

    //     store.unlockMargin(user, position.margin);
    //     store.removePosition(user, _market);

    //     // Credit fees
    //     uint256 fee = position.size * market.fee / BPS_DIVIDER;
    //     pool.creditFee(user, _market, fee, false);

    //     emit PositionDecreased(
    //         0,
    //         user,
    //         _market,
    //         !position.isLong,
    //         position.size,
    //         position.margin,
    //         chainlinkPrice,
    //         position.margin,
    //         position.size,
    //         position.price,
    //         position.fundingTracker,
    //         fee,
    //         0,
    //         0,
    //         0
    //         );
    // }