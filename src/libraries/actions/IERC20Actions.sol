// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


library IERC20Actions{

    function transferIn(address user, uint256 amount) external onlyContract {
        IERC20(currency).safeTransferFrom(user, address(this), amount);
    }

    function transferOut(address user, uint256 amount) external onlyContract {
        IERC20(currency).safeTransfer(user, amount);
    }

    function getUserPoolBalance(address user) external view returns (uint256) {
        uint256 clpSupply = IERC20(clp).totalSupply();
        if (clpSupply == 0) return 0;
        return IERC20(clp).balanceOf(user) * poolBalance / clpSupply;
    }

}