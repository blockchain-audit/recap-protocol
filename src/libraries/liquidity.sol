function validateAddLiquidity(uint256 amount) internal view {
    if(amount == 0)
       revert Errors.
}

function executeAddLiquidity(uint256 amount, uint256 balance, uint256 clpSupply, address user) internal {
    store.incrementPoolBalance(amount);
    uint256 clpAmount = balance == 0 || clpSupply == 0 ? amount : amount * clpSupply / balance;
    store.mintCLP(user, clpAmount);
    store.transferIn(user, amount);
    emit AddLiquidity(user, amount, clpAmount, store.poolBalance());
    require(store.poolBalance() >= amount, "Invariant: Pool balance mismatch after adding liquidity");
}
