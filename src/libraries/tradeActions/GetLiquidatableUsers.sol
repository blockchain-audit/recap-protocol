    // function getLiquidatableUsers() public view returns (address[] memory usersToLiquidate) {
    //     uint256 length = store.getUsersWithLockedMarginLength();
    //     address[] memory _users = new address[](length);
    //     uint256 j;
    //     for (uint256 i = 0; i < length; i++) {
    //         address user = store.getUserWithLockedMargin(i);
    //         int256 equity = int256(store.getBalance(user)) + getUpl(user);
    //         uint256 lockedMargin = store.getLockedMargin(user);
    //         uint256 marginLevel;
    //         if (equity <= 0) {
    //             marginLevel = 0;
    //         } else {
    //             marginLevel = BPS_DIVIDER * uint256(equity) / lockedMargin;
    //         }
    //         if (marginLevel < store.minimumMarginLevel()) {
    //             _users[j] = user;
    //             ++j;
    //         }
    //     }
    //     // Return trimmed result containing only users to be liquidated
    //     usersToLiquidate = new address[](j);
    //     for (uint256 i = 0; i < j; i++) {
    //         usersToLiquidate[i] = _users[i];
    //     }
    //     return usersToLiquidate;
    // }