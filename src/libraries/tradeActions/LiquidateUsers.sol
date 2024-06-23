    // function liquidateUsers() external {
    //     address[] memory usersToLiquidate = getLiquidatableUsers();
    //     uint256 userLength = usersToLiquidate.length;
    //     uint256 liquidatorFees;

    //     for (uint256 i = 0; i < userLength; i++) {
    //         uint256 userFees;

    //         address user = usersToLiquidate[i];
    //         IStore.Position[] memory positions = store.getUserPositions(user);
    //         uint256 posLength = positions.length;

    //         for (uint256 j = 0; j < posLength; j++) {
    //             IStore.Position memory position = positions[j];
    //             IStore.Market memory market = store.getMarket(position.market);

    //             uint256 fee = position.size * market.fee / BPS_DIVIDER;
    //             uint256 liquidatorFee = fee * store.keeperFeeShare() / BPS_DIVIDER;
    //             fee -= liquidatorFee;
    //             liquidatorFees += liquidatorFee;
    //             userFees += fee + liquidatorFee;

    //             store.decrementOI(position.market, position.size, position.isLong);
    //             _updateFundingTracker(position.market);
    //             store.removePosition(user, position.market);

    //             uint256 chainlinkPrice = chainlink.getPrice(market.feed);

    //             // Credit fees
    //             pool.creditFee(user, position.market, fee, true);

    //             emit PositionLiquidated(
    //                 user,
    //                 position.market,
    //                 position.isLong,
    //                 position.size,
    //                 position.margin,
    //                 chainlinkPrice,
    //                 fee,
    //                 liquidatorFee
    //                 );
    //         }

    //         // Credit full user balance minus fees
    //         pool.creditTraderLoss(user, "all", store.getBalance(user) - userFees);
    //         // set margin and user balance to zero
    //         store.unlockMargin(user, store.getLockedMargin(user));
    //         store.decrementBalance(user, store.getBalance(user));
    //     }

    //     // credit liquidator fees
    //     store.incrementBalance(msg.sender, liquidatorFees);
    // }