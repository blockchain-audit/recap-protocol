    // function _increasePosition(IStore.Order memory order, uint256 price, address keeper) internal {
    //     IStore.Position memory position = store.getPosition(order.user, order.market);

    //     store.incrementOI(order.market, order.size, order.isLong);

    //     _updateFundingTracker(order.market);

    //     uint256 averagePrice = (position.size * position.price + order.size * price) / (position.size + order.size);

    //     if (position.size == 0) {
    //         position.user = order.user;
    //         position.market = order.market;
    //         position.timestamp = uint64(block.timestamp);
    //         position.isLong = order.isLong;
    //         position.fundingTracker = store.getFundingTracker(order.market);
    //     }

    //     position.size += order.size;
    //     position.margin += order.margin;
    //     position.price = averagePrice;

    //     store.addOrUpdatePosition(position);

    //     if (order.orderId > 0) {
    //         store.removeOrder(order.orderId);
    //     }

    //     // Credit fees
    //     uint256 fee = order.fee;
    //     uint256 keeperFee = fee * store.keeperFeeShare() / BPS_DIVIDER;
    //     fee -= keeperFee;
    //     pool.creditFee(order.user, order.market, fee, false);
    //     store.incrementBalance(keeper, keeperFee);

    //     emit PositionIncreased(
    //         order.orderId,
    //         order.user,
    //         order.market,
    //         order.isLong,
    //         order.size,
    //         order.margin,
    //         price,
    //         position.margin,
    //         position.size,
    //         position.price,
    //         position.fundingTracker,
    //         fee,
    //         keeperFee
    //         );
    // }