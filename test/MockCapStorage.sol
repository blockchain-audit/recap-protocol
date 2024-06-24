// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;

import { CapStorage, Market } from "../src/contracts/CapStorage.sol";
import "../src/contracts/Trade.sol";
import "../src/contracts/Pool.sol";
import "../src/tokens/CLP.sol";
import "../src/mocks/MockToken.sol";
import "../src/mocks/MockChainlink.sol";

contract MockCapStorage is CapStorage {
    
    constructor() {
        MockToken usdc = new MockToken("USDC", "USDC", 6);
        MockChainlink chainlink = new MockChainlink();
        Trade trade = new Trade();
        Pool pool = new Pool();
        CLP clp = new CLP(address(this));

        address treasury = address(0x10); // Ensure this is a valid address in your network
        address swapRouter = address(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        address quoter = address(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);

        // Initialize contract addresses
        state.contractAddresses.gov = address(0x1); // Sample address initialization
        state.contractAddresses.currency = address(usdc);
        state.contractAddresses.clp = address(clp);
        state.contractAddresses.swapRouter = swapRouter;
        state.contractAddresses.quoter = quoter;
        state.contractAddresses.weth = address(0x6); // Ensure this is a valid address in your network
        state.contractAddresses.trade = address(trade);
        state.contractAddresses.pool = address(pool);
        state.contractAddresses.treasury = treasury;

        // Initialize fees
        state.fees.poolFeeShare = 1000; // Sample fee initialization
        state.fees.keeperFeeShare = 500;
        state.fees.poolWithdrawalFee = 50;
        state.fees.minimumMarginLevel = 10000;

        // Initialize balances
        state.balances.bufferBalance = 0;
        state.balances.poolBalance = 0;
        state.balances.poolLastPaid = block.timestamp;

        // Initialize buffer
        state.buffer.bufferPayoutPeriod = 86400; // Sample buffer initialization (1 day in seconds)

        // Initialize market data
        state.marketData.marketList.push("ETH/USD");
        state.marketData.markets["ETH/USD"] = Market({
            symbol: "ETH/USD",
            feed: address(0xA),
            minSettlementTime: 3600, // 1 hour
            maxLeverage: 100,
            fee: 30,
            fundingFactor: 100,
            maxOI: 10000,
            minSize: 1 ether
        });

        // Initialize any other mappings or structs within State as per your contract logic.
    }

    function getUserBalance(address user) public returns (uint256) {
        return state.userBalances.balances[user];
    }

    function getTradeAddress() public returns (address) {
        return state.contractAddresses.trade;
    }

    function setUserBalance(address user, uint256 amount) public {
        state.userBalances.balances[user] = amount;
    }
}
