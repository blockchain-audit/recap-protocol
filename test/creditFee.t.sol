//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "./utils/TestUtils.sol";

contract CreditFeeTest is TestUtils {
    
    uint256 fee = _getOrderFee("ETH-USD", ethLong.size) + _getOrderFee("BTC-USD", btcLong.size);
    uint256 keeperFee = fee * store.keeperFeeShare() / BPS_DIVIDER;
    fee -= keeperFee;
    uint256 poolFee = fee * store.poolFeeShare() / BPS_DIVIDER;
    uint256 treasuryFee = fee - poolFee;

    assertEq(store.poolBalance(), poolFee, "!poolFee");
    assertEq(IERC20(usdc).balanceOf(treasury), treasuryFee, "!treasuryFee");
    assertEq(store.getBalance(address(this)), keeperFee, "!keeperFee");
    
}

