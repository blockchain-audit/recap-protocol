
    // function getUserPositionsWithUpls(address user)
    //     external
    //     view
    //     returns (IStore.Position[] memory _positions, int256[] memory _upls)
    // {
    //     _positions = store.getUserPositions(user);
    //     uint256 length = _positions.length;
    //     _upls = new int256[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         IStore.Position memory position = _positions[i];

    //         IStore.Market memory market = store.getMarket(position.market);

    //         uint256 chainlinkPrice = chainlink.getPrice(market.feed);
    //         if (chainlinkPrice == 0) continue;

    //         (int256 pnl,) = _getPnL(
    //             position.market, position.isLong, chainlinkPrice, position.price, position.size, position.fundingTracker
    //         );

    //         _upls[i] = pnl;
    //     }

    //     return (_positions, _upls);
    // }


