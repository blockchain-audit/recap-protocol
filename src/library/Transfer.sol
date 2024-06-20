// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {RecapStorage} from "../state.sol";
import "../state.sol";

library Transfer {
    using SafeERC20 for IERC20;

    function transferIn(State storage state, address user, uint256 amount) external {
        IERC20(state.store.currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(State storage state, address user, uint256 amount) external {
        IERC20(state.store.currency).safeTransfer(user, amount);
    }
}
