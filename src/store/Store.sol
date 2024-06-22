// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "lib/v3-periphery/contracts/interfaces/IQuoter.sol";



import "../interfaces/IStore.sol";
import "../interfaces/ICLP.sol";
import "./storeView.sol";
//import {StateStore} from "src/store/storeStorage.sol";
import {StateStore} from "./storeStorage.sol";
//import {Map} from "src/store/storeStorage.sol";

contract Store is IStore, storeView {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    State s;
    
    StateStore state_store;
    Map _mapping;

    // constants

    uint256 public constant BPS_DIVIDER = 10000;
    uint256 public constant MAX_FEE = 500; // in bps = 5%
    uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

   
    // Modifiers

    modifier onlyContract() {
        require(msg.sender == state_store.trade || msg.sender == state_store.pool, "!contract");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == state_store.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        state_store.gov = _gov;
    }

    // Gov methods

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = state_store.gov;
        state_store.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _pool, address _currency, address _clp) external onlyGov {
        state_store.trade = _trade;
        state_store.pool = _pool;
        state_store.currency = _currency;
        state_store.clp = _clp;
    }

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external onlyGov {
        state_store.swapRouter = _swapRouter;
        state_store.quoter = _quoter;
        state_store.weth = _weth; // _weth = WMATIC on Polygon
    }

    function setPoolFeeShare(uint256 amount) external onlyGov {
        state_store.poolFeeShare = amount;
    }

    function setKeeperFeeShare(uint256 amount) external onlyGov {
        require(amount <= MAX_KEEPER_FEE_SHARE, "!max-keeper-fee-share");
        state_store.keeperFeeShare = amount;
    }

    function setPoolWithdrawalFee(uint256 amount) external onlyGov {
        require(amount <= MAX_POOL_WITHDRAWAL_FEE, "!max-pool-withdrawal-fee");
        state_store.poolWithdrawalFee = amount;
    }

    function setMinimumMarginLevel(uint256 amount) external onlyGov {
        state_store.minimumMarginLevel = amount;
    }

    function setBufferPayoutPeriod(uint256 amount) external onlyGov {
        state_store.bufferPayoutPeriod = amount;
    }

    function setMarket(string calldata market, Market calldata marketInfo) external onlyGov {
        require(marketInfo.fee <= MAX_FEE, "!max-fee");
        markets[market] = marketInfo;
        for (uint256 i = 0; i < marketList.length; i++) {
            if (keccak256(abi.encodePacked(marketList[i])) == keccak256(abi.encodePacked(market))) return;
        }
        marketList.push(market);
    }

    // Methods

    function transferIn(address user, uint256 amount) external onlyContract {
        IERC20(currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(address user, uint256 amount) external onlyContract {
        IERC20(currency).safeTransfer(user, amount);
    }

    // CLP methods
    function mintCLP(address user, uint256 amount) external onlyContract {
        ICLP(state_store.clp).mint(user, amount);
    }

    function burnCLP(address user, uint256 amount) external onlyContract {
        ICLP(state_store.clp).burn(user, amount);
    }

    // function getCLPSupply() external view returns (uint256) {
    //     return IERC20(s.clp).totalSupply();
    // }

    // Uniswap methods
    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        onlyContract
        returns (uint256 amountOut)
    {
        require(address(swapRouter) != address(0), "!swapRouter");

        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).safeApprove(address(swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(swapRouter).exactInputSingle{value: msg.value}(params);
    }

    // Function is not marked as view because it relies on calling non-view functions
    // Not gas efficient so shouldnt be called on-chain
    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut)
    {
        return IQuoter(quoter).quoteExactInputSingle(tokenIn, currency, poolFee, amountIn, 0);
    }

    // User balance
    function incrementBalance(address user, uint256 amount) external onlyContract {
        balances[user] += amount;
    }

    function decrementBalance(address user, uint256 amount) external onlyContract {
        require(amount <= balances[user], "!balance");
        balances[user] -= amount;
    }

    // function getBalance(address user) external view returns (uint256) {
    //     return balances[user];
    // }

    // Pool
    function incrementPoolBalance(uint256 amount) external onlyContract {
        state_store.poolBalance += amount;
    }

    function decrementPoolBalance(uint256 amount) external onlyContract {
        state_store.poolBalance -= amount;
    }

    function setPoolLastPaid(uint256 timestamp) external onlyContract {
        state_store.poolLastPaid = timestamp;
    }

    // function getUserPoolBalance(address user) external view returns (uint256) {
    //     uint256 clpSupply = IERC20(clp).totalSupply();
    //     if (clpSupply == 0) return 0;
    //     return IERC20(clp).balanceOf(user) * poolBalance / clpSupply;
    // }

    // Buffer
    function incrementBufferBalance(uint256 amount) external onlyContract {
        state_store.bufferBalance += amount;
    }

    function decrementBufferBalance(uint256 amount) external onlyContract {
        state_store.bufferBalance -= amount;
    }

    // Margin
    function lockMargin(address user, uint256 amount) external onlyContract {
        lockedMargins[user] += amount;
        state_store.usersWithLockedMargin.add(user);
    }

    function unlockMargin(address user, uint256 amount) external onlyContract {
        if (amount > lockedMargins[user]) {
            _mapping.lockedMargins[user] = 0;
        } else {
            _mapping.lockedMargins[user] -= amount;
        }
        if (_mapping.lockedMargins[user] == 0) {
            state_store.usersWithLockedMargin.remove(user);
        }
    }

    // function getLockedMargin(address user) external view returns (uint256) {
    //     return lockedMargins[user];
    // }

    // function getUsersWithLockedMarginLength() external view returns (uint256) {
    //     return s.usersWithLockedMargin.length();
    // }

    // function getUserWithLockedMargin(uint256 i) external view returns (address) {
    //     return usersWithLockedMargin.at(i);
    // }

    // Open interest
    function incrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
             _mapping.OILong[market] += size;
            require(_mapping.markets[market].maxOI >= _mapping.OILong[market], "!max-oi");
        } else {
             _mapping.OIShort[market] += size;
            require(markets[market].maxOI >=  _mapping.OIShort[market], "!max-oi");
        }
    }

    function decrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            if (size >  _mapping.OILong[market]) {
                 _mapping.OILong[market] = 0;
            } else {
                 _mapping.OILong[market] -= size;
            }
        } else {
            if (size > OIShort[market]) {
                 _mapping.OIShort[market] = 0;
            } else {
                 _mapping.OIShort[market] -= size;
            }
        }
    }

    // function getOILong(string calldata market) external view returns (uint256) {
    //     return OILong[market];
    // }

    // function getOIShort(string calldata market) external view returns (uint256) {
    //     return OIShort[market];
    // }

    // Orders
    function addOrder(Order memory order) external onlyContract returns (uint256) {
        uint256 nextOrderId = ++orderId;
        order.orderId = uint72(nextOrderId);
        _mapping.orders[nextOrderId] = order;
        _mapping.userOrderIds[order.user].add(nextOrderId);
        orderIds.add(nextOrderId);
        return nextOrderId;
    }

    function updateOrder(Order calldata order) external onlyContract {
        _mapping.orders[order.orderId] = order;
    }

    function removeOrder(uint256 _orderId) external onlyContract {
        Order memory order = _mapping.orders[_orderId];
        if (order.size == 0) return;
        _mapping.userOrderIds[order.user].remove(_orderId);
        orderIds.remove(_orderId);
        delete _mapping.orders[_orderId];
    }

    // function getOrder(uint256 id) external view returns (Order memory _order) {
    //     return orders[id];
    // }

    // function getOrders() external view returns (Order[] memory _orders) {
    //     uint256 length = orderIds.length();
    //     _orders = new Order[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         _orders[i] = orders[orderIds.at(i)];
    //     }
    //     return _orders;
    // }

    // function getUserOrders(address user) external view returns (Order[] memory _orders) {
    //     uint256 length = s.userOrderIds[user].length();
    //     _orders = new Order[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         _orders[i] = orders[s.userOrderIds[user].at(i)];
    //     }
    //     return _orders;
    // }

    // Positions
    function addOrUpdatePosition(Position calldata position) external onlyContract {
        bytes32 key = _getPositionKey(position.user, position.market);
        _mapping.positions[key] = position;
        _mapping.positionKeysForUser[position.user].add(key);
        positionKeys.add(key);
    }

    function removePosition(address user, string calldata market) external onlyContract {
        bytes32 key = _getPositionKey(user, market);
        _mapping.positionKeysForUser[user].remove(key);
        positionKeys.remove(key);
        delete _mapping.positions[key];
    }

    // function getUserPositions(address user) external view returns (Position[] memory _positions) {
    //     uint256 length = positionKeysForUser[user].length();
    //     _positions = new Position[](length);
    //     for (uint256 i = 0; i < length; i++) {
    //         _positions[i] = positions[positionKeysForUser[user].at(i)];
    //     }
    //     return _positions;
    // }

    // function getPosition(address user, string calldata market) public view returns (Position memory position) {
    //     bytes32 key = _getPositionKey(user, market);
    //     return positions[key];
    // }

    function _getPositionKey(address user, string calldata market) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(user, market));
    }

    // Markets
    // function getMarket(string calldata market) external view returns (Market memory _market) {
    //     return markets[market];
    // }

    // function getMarketList() external view returns (string[] memory) {
    //     return marketList;
    // }

    // Funding
    function setFundingLastUpdated(string calldata market, uint256 timestamp) external onlyContract {
        _mapping.fundingLastUpdated[market] = timestamp;
    }

    function updateFundingTracker(string calldata market, int256 fundingIncrement) external onlyContract {
        _mapping.fundingTrackers[market] += fundingIncrement;
    }

    // function getFundingLastUpdated(string calldata market) external view returns (uint256) {
    //     return s.fundingLastUpdated[market];
    // }

    // function getFundingFactor(string calldata market) external view returns (uint256) {
    //     return markets[market].fundingFactor;
    // }

    // function getFundingTracker(string calldata market) external view returns (int256) {
    //     return s.fundingTrackers[market];
    // }
}
