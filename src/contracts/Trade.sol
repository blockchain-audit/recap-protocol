pragma solidity ^0.8.24;

import "./CapStorage.sol";
import "../interfaces/ITrade.sol";
import {Deposit} from "../libraries/tradeActions/Deposit.sol";
import {DepositThroughUniswap} from "../libraries/tradeActions/DepositThroughUniswap.sol";
import {Withdraw} from "../libraries/tradeActions/Withdraw.sol";
contract Trade is CapStorage{
    using Deposit for State;
    using DepositThroughUniswap for State;
    using Withdraw for State;

    function deposit(uint256 amount) external{
        state.validateDeposit(amount);
        state.executeDeposit(amount);
    }

    function depositThroughUniswap(address tokenIn, uint256 amountIn, uint256 amountOutMin, uint24 poolFee) external payable{
            state.validateDepositThroughUniswap(tokenIn,amountIn,amountOutMin,poolFee);
            state.executeDepositThroughUniswap(tokenIn,amountIn,amountOutMin,poolFee);
        } 
    function withdraw(uint256 amount) external{
        state.validateWithdraw(amount);
        state.executeWithdraw(amount);
    }
    function cancelOrder(uint256 orderId) external{}

    function cancelOrders(uint256[] memory orderIds) external{}

    function closePositionWithoutProfit(string memory _market) external{}

    function executeOrders() external{}

    function getAccruedFunding(string memory market, uint256 intervals) external view returns (int256){}

    function getExecutableOrderIds() external view returns (uint256[] memory orderIdsToExecute){}

    function getLiquidatableUsers() external view returns (address[] memory usersToLiquidate){}

    // function getMarketsWithPrices() external view returns (IStore.Market[] memory _markets, uint256[] memory _prices){}

    function getUpl(address user) external view returns (int256 upl){}

    // function getUserPositionsWithUpls(address user)
    //     external
    //     view
    //     returns (IStore.Position[] memory _positions, int256[] memory _upls){}

    function link(address _chainlink, address _pool, address _store) external{}

    function liquidateUsers() external{}

    // function submitOrder(IStore.Order memory params, uint256 tpPrice, uint256 slPrice) external{}

    function updateGov(address _gov) external{}

    function updateOrder(uint256 orderId, uint256 price) external{}

   

}