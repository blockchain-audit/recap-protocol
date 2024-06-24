// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/contracts/Trade.sol";
import { CapStorage } from "../src/contracts/CapStorage.sol"; // Import CapStorage contract

contract TradeTest is Test {
    Trade private tradeContract;
    CapStorage private capStorage; // Define CapStorage contract instance

    function setUp() public {
        // Deploy a new instance of CapStorage
        capStorage = new CapStorage();

        // Deploy Trade contract with CapStorage instance
        tradeContract = new Trade();
        tradeContract.setCapStorage(address(capStorage)); // Set CapStorage address in Trade contract

        // Initialize State variables through CapStorage
        State storage state = capStorage.state();

        // Initialize contract addresses
        state.contractAddresses.gov = address(0x1);
        state.contractAddresses.currency = address(0x2);
        state.contractAddresses.clp = address(0x3);
        state.contractAddresses.swapRouter = address(0x4);
        state.contractAddresses.quoter = address(0x5);
        state.contractAddresses.weth = address(0x6);
        state.contractAddresses.trade = address(tradeContract); // Address of Trade contract
        state.contractAddresses.pool = address(0x8);
        state.contractAddresses.treasury = address(0x9);

        // Initialize Fees
        state.fees.poolFeeShare = 100; // Example values, adjust as necessary
        state.fees.keeperFeeShare = 50;
        state.fees.poolWithdrawalFee = 10;
        state.fees.minimumMarginLevel = 1000;

        // Initialize Balances
        state.balances.bufferBalance = 0;
        state.balances.poolBalance = 0;
        state.balances.poolLastPaid = block.timestamp;

        // Initialize Buffer
        state.buffer.bufferPayoutPeriod = 86400; // Example buffer payout period in seconds

        // Initialize other data structures as needed (OrderData, MarketData, etc.)

        // Initialize contract-specific mappings or sets
        // For example, initialize marketData.marketList if necessary
        state.marketData.marketList.push("ETH/USD");

        // Add more initializations as per your contract's requirements

        // Log success
        console.log("Setup completed successfully");
    }

    function testDeposit() public {
        // Simulate a deposit action
        address user = address(vm.addr(1)); // Replace with a test user address
        uint256 amount = 1000; // Amount to deposit

        // Ensure the user has sufficient balance to deposit
        State storage state = capStorage.state();
        state.userBalances.balances[user] = 2000; // Example: User has 2000 tokens initially

        // Call the deposit function from Trade contract
        tradeContract.deposit(user, amount);

        // Assertions to verify the deposit action
        // Example assertions (adjust based on actual logic):
        assert(state.userBalances.balances[user] == 3000); // User balance should increase by deposited amount
        assert(state.balances.poolBalance == amount); // Pool balance should reflect the deposited amount

        // Additional assertions as per your contract's logic
        // Example: Check emitted events or other state changes

        // Example: Check that deposit with zero amount reverts
        bool didRevert;
        try tradeContract.deposit(user, 0) {
            didRevert = false;
        } catch {
            didRevert = true;
        }
        assert(didRevert);

        // Example: Check that insufficient balance reverts
        try tradeContract.deposit(user, 3000) {
            didRevert = false;
        } catch {
            didRevert = true;
        }
        assert(didRevert);

        // Log success
        console.log("Deposit function tested successfully");
    }
}
