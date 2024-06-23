    // function _decreasePosition(IStore.Order memory order, uint256 price, address keeper) internal {
    //     IStore.Position memory position = store.getPosition(order.user, order.market);
    //     IStore.Market memory market = store.getMarket(order.market);

    //     uint256 executedOrderSize = position.size > order.size ? order.size : position.size;
    //     uint256 remainingOrderSize = order.size - executedOrderSize;

    //     if (order.isReduceOnly) {
    //         // order.margin = 0
    //         // A fee (order.fee) corresponding to order.size was taken from balance on submit. Only fee corresponding to executedOrderSize should be charged, rest should be returned, if any
    //         store.incrementBalance(order.user, order.fee * remainingOrderSize / order.size);
    //     }

    //     // Funding update
    //     store.decrementOI(order.market, order.size, position.isLong);
    //     _updateFundingTracker(order.market);

    //     // P/L

    //     (int256 pnl, int256 fundingFee) =
    //         _getPnL(order.market, position.isLong, price, position.price, executedOrderSize, position.fundingTracker);

    //     uint256 marginToFree = executedOrderSize / market.maxLeverage;

    //     position.size -= executedOrderSize;
    //     position.margin -= marginToFree;
    //     position.fundingTracker = store.getFundingTracker(order.market);

    //     if (pnl < 0) {
    //         uint256 absPnl = uint256(-1 * pnl);
    //         // credit trader loss to pool
    //         pool.creditTraderLoss(order.user, order.market, absPnl);
    //     } else {
    //         pool.debitTraderProfit(order.user, order.market, uint256(pnl));
    //     }

    //     store.unlockMargin(order.user, marginToFree);

    //     if (position.size == 0) {
    //         store.removePosition(order.user, order.market);
    //     } else {
    //         store.addOrUpdatePosition(position);
    //     }

    //     store.removeOrder(order.orderId);

    //     // Open position in opposite direction if size remains
    //     if (!order.isReduceOnly && remainingOrderSize > 0) {
    //         IStore.Order memory nextOrder = IStore.Order({
    //             orderId: 0,
    //             user: order.user,
    //             market: order.market,
    //             margin: remainingOrderSize / market.maxLeverage,
    //             size: remainingOrderSize,
    //             price: 0,
    //             isLong: order.isLong,
    //             orderType: 0,
    //             fee: uint192(order.fee * remainingOrderSize / order.size),
    //             isReduceOnly: false,
    //             timestamp: uint64(block.timestamp)
    //         });

    //         _increasePosition(nextOrder, price, keeper);
    //     }

    //     // Credit fees
    //     uint256 fee = order.fee;
    //     uint256 keeperFee = fee * store.keeperFeeShare() / BPS_DIVIDER;
    //     fee -= keeperFee;
    //     pool.creditFee(order.user, order.market, fee, false);
    //     store.incrementBalance(keeper, keeperFee);

    //     emit PositionDecreased(
    //         order.orderId,
    //         order.user,
    //         order.market,
    //         order.isLong,
    //         executedOrderSize,
    //         marginToFree,
    //         price,
    //         position.margin,
    //         position.size,
    //         position.price,
    //         position.fundingTracker,
    //         fee,
    //         keeperFee,
    //         pnl,
    //         fundingFee
    //         );
    // }