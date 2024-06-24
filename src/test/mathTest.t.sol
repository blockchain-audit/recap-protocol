function test_calculateCLPAmount() public {
    uint256 amount = 1000;
    uint256 clpSupply = 5000;
    uint256 balance = 2000;
    uint256 expectedAmount = amount * clpSupply / balance;

    uint256 result = Math.calculateCLPAmount(amount, clpSupply, balance);
    assertEq(result, expectedAmount, "Incorrect CLP amount calculated");

    // Test case where balance is zero
    balance = 0;
    expectedAmount = amount;
    result = Math.calculateCLPAmount(amount, clpSupply, balance);
    assertEq(result, expectedAmount, "Incorrect CLP amount calculated when balance is zero");

    // Test case where clpSupply is zero
    balance = 2000;
    clpSupply = 0;
    expectedAmount = amount;
    result = Math.calculateCLPAmount(amount, clpSupply, balance);
    assertEq(result, expectedAmount, "Incorrect CLP amount calculated when CLP supply is zero");

    // Test case where both balance and clpSupply are zero
    balance = 0;
    clpSupply = 0;
    expectedAmount = amount;
    result = Math.calculateCLPAmount(amount, clpSupply, balance);
    assertEq(result, expectedAmount, "Incorrect CLP amount calculated when both balance and CLP supply are zero");
}
