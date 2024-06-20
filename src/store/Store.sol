// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.11;

import "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";
import "lib/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "lib/v3-periphery/contracts/interfaces/IQuoter.sol";

// import "../interfaces/IStore.sol";
import "../interfaces/ICLP.sol";

import "./ViewFuncStore.sol";

contract Store is IStore, ViewFuncStore{

    
    // constants
    uint256 public constant BPS_DIVIDER = 10000;
    uint256 public constant MAX_FEE = 500; // in bps = 5%
    uint256 public constant MAX_KEEPER_FEE_SHARE = 2000; // in bps = 20%
    uint256 public constant MAX_POOL_WITHDRAWAL_FEE = 500; // in bps = 5%
    uint256 public constant FUNDING_INTERVAL = 1 hours; // In seconds.

    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;
    

    // Modifiers

    modifier onlyContract() {
        require(msg.sender == stateStore.trade || msg.sender == stateStore.pool, "!contract");
        _;
    }

    modifier onlyGov() {
        require(msg.sender == stateStore.gov, "!governance");
        _;
    }

    constructor(address _gov) {
        stateStore.gov = _gov;

        // Variables
        stateStore.poolFeeShare = 5000; // in bps
        stateStore.keeperFeeShare = 1000; // in bps
        stateStore.poolWithdrawalFee = 10; // in bps
        stateStore.minimumMarginLevel = 2000; // 20% in bps, at which account is liquidated
        stateStore.bufferPayoutPeriod = 7 days;
    }

    // Gov methods

    function updateGov(address _gov) external onlyGov {
        require(_gov != address(0), "!address");

        address oldGov = stateStore.gov;
        stateStore.gov = _gov;

        emit GovernanceUpdated(oldGov, _gov);
    }

    function link(address _trade, address _pool, address _currency, address _clp) external onlyGov {
        stateStore.trade = _trade;
        stateStore.pool = _pool;
        stateStore.currency = _currency;
        stateStore.clp = _clp;
    }

    function linkUniswap(address _swapRouter, address _quoter, address _weth) external onlyGov {
        stateStore.swapRouter = _swapRouter;
        stateStore.quoter = _quoter;
        stateStore.weth = _weth; // _weth = WMATIC on Polygon
    }

    function setPoolFeeShare(uint256 amount) external onlyGov {
        stateStore.poolFeeShare = amount;
    }

    function setKeeperFeeShare(uint256 amount) external onlyGov {
        require(amount <= MAX_KEEPER_FEE_SHARE, "!max-keeper-fee-share");
        stateStore.keeperFeeShare = amount;
    }

    function setPoolWithdrawalFee(uint256 amount) external onlyGov {
        require(amount <= MAX_POOL_WITHDRAWAL_FEE, "!max-pool-withdrawal-fee");
        stateStore.poolWithdrawalFee = amount;
    }

    function setMinimumMarginLevel(uint256 amount) external onlyGov {
        stateStore.minimumMarginLevel = amount;
    }

    function setBufferPayoutPeriod(uint256 amount) external onlyGov {
        stateStore.bufferPayoutPeriod = amount;
    }

    function setMarket(string calldata market, Market calldata marketInfo) external onlyGov {
        require(marketInfo.fee <= MAX_FEE, "!max-fee");
        stateStore.markets[market] = marketInfo;
        for (uint256 i = 0; i < stateStore.marketList.length; i++) {
            if (keccak256(abi.encodePacked(stateStore.marketList[i])) == keccak256(abi.encodePacked(market))) return;
        }
        stateStore.marketList.push(market);
    }

    // Methods

    function transferIn(address user, uint256 amount) external onlyContract {
        IERC20(stateStore.currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(address user, uint256 amount) external onlyContract {
        IERC20(stateStore.currency).safeTransfer(user, amount);
    }

    // CLP methods
    function mintCLP(address user, uint256 amount) external onlyContract {
        ICLP(stateStore.clp).mint(user, amount);
    }

    function burnCLP(address user, uint256 amount) external onlyContract {
        ICLP(stateStore.clp).burn(user, amount);
    }

    

    // Uniswap methods
    function swapExactInputSingle(address user, uint256 amountIn, uint256 amountOutMin, address tokenIn, uint24 poolFee)
        external
        payable
        onlyContract
        returns (uint256 amountOut)
    {
        require(address(stateStore.swapRouter) != address(0), "!swapRouter");

        if (msg.value != 0) {
            // there are no direct ETH pairs in Uniswapv3, so router converts ETH to WETH before swap
            tokenIn = stateStore.weth;
            amountIn = msg.value;
        } else {
            // transfer token to be swapped
            IERC20(tokenIn).safeTransferFrom(user, address(this), amountIn);
            IERC20(tokenIn).safeApprove(address(stateStore.swapRouter), amountIn);
        }

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: stateStore.currency, // store supported currency
            fee: poolFee,
            recipient: address(this),
            deadline: block.timestamp + 15,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin, // swap reverts if amountOut < amountOutMin
            sqrtPriceLimitX96: 0
        });

        // The call to `exactInputSingle` executes the swap.
        amountOut = ISwapRouter(stateStore.swapRouter).exactInputSingle{value: msg.value}(params);
    }

    // Function is not marked as view because it relies on calling non-view functions
    // Not gas efficient so shouldnt be called on-chain
    function getEstimatedOutputTokens(uint256 amountIn, address tokenIn, uint24 poolFee)
        external
        returns (uint256 amountOut)
    {
        return IQuoter(stateStore.quoter).quoteExactInputSingle(tokenIn, stateStore.currency, poolFee, amountIn, 0);
    }

    // User balance
    function incrementBalance(address user, uint256 amount) external onlyContract {
        stateStore.balances[user] += amount;
    }

    function decrementBalance(address user, uint256 amount) external onlyContract {
        require(amount <= stateStore.balances[user], "!balance");
        stateStore.balances[user] -= amount;
    }

    

    // Pool
    function incrementPoolBalance(uint256 amount) external onlyContract {
        stateStore.poolBalance += amount;
    }

    function decrementPoolBalance(uint256 amount) external onlyContract {
        stateStore.poolBalance -= amount;
    }

    function setPoolLastPaid(uint256 timestamp) external onlyContract {
        stateStore.poolLastPaid = timestamp;
    }


    // Buffer
    function incrementBufferBalance(uint256 amount) external onlyContract {
        stateStore.bufferBalance += amount;
    }

    function decrementBufferBalance(uint256 amount) external onlyContract {
        stateStore.bufferBalance -= amount;
    }

    // Margin
    function lockMargin(address user, uint256 amount) external onlyContract {
        stateStore.lockedMargins[user] += amount;
        stateStore.usersWithLockedMargin.add(user);
    }

    function unlockMargin(address user, uint256 amount) external onlyContract {
        if (amount > stateStore.lockedMargins[user]) {
            stateStore.lockedMargins[user] = 0;
        } else {
            stateStore.lockedMargins[user] -= amount;
        }
        if (stateStore.lockedMargins[user] == 0) {
            stateStore.usersWithLockedMargin.remove(user);
        }
    }

    
    // Open interest
    function incrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            stateStore.OILong[market] += size;
            require(stateStore.markets[market].maxOI >= stateStore.OILong[market], "!max-oi");
        } else {
            stateStore.OIShort[market] += size;
            require(stateStore.markets[market].maxOI >= stateStore.OIShort[market], "!max-oi");
        }
    }

    function decrementOI(string calldata market, uint256 size, bool isLong) external onlyContract {
        if (isLong) {
            if (size > stateStore.OILong[market]) {
                stateStore.OILong[market] = 0;
            } else {
                stateStore.OILong[market] -= size;
            }
        } else {
            if (size > stateStore.OIShort[market]) {
                stateStore.OIShort[market] = 0;
            } else {
                stateStore.OIShort[market] -= size;
            }
        }
    }


    // Orders
    function addOrder(Order memory order) external onlyContract returns (uint256) {
        uint256 nextOrderId = ++stateStore.orderId;
        order.orderId = uint72(nextOrderId);
        stateStore.orders[nextOrderId] = order;
        stateStore.userOrderIds[order.user].add(nextOrderId);
        stateStore.orderIds.add(nextOrderId);
        return nextOrderId;
    }

    function updateOrder(Order calldata order) external onlyContract {
        stateStore.orders[order.orderId] = order;
    }

    function removeOrder(uint256 _orderId) external onlyContract {
        Order memory order = stateStore.orders[_orderId];
        if (order.size == 0) return;
        stateStore.userOrderIds[order.user].remove(_orderId);
        stateStore.orderIds.remove(_orderId);
        delete stateStore.orders[_orderId];
    }

   

    

    // Positions
    function addOrUpdatePosition(Position calldata position) external onlyContract {
        bytes32 key = _getPositionKey(position.user, position.market);
        stateStore.positions[key] = position;
        stateStore.positionKeysForUser[position.user].add(key);
        stateStore.positionKeys.add(key);
    }

    function removePosition(address user, string calldata market) external onlyContract {
        bytes32 key = _getPositionKey(user, market);
        stateStore.positionKeysForUser[user].remove(key);
        stateStore.positionKeys.remove(key);
        delete stateStore.positions[key];
    }

   



    

    // Funding
    function setFundingLastUpdated(string calldata market, uint256 timestamp) external onlyContract {
        stateStore.fundingLastUpdated[market] = timestamp;
    }

    function updateFundingTracker(string calldata market, int256 fundingIncrement) external onlyContract {
        stateStore.fundingTrackers[market] += fundingIncrement;
    }

    
}
