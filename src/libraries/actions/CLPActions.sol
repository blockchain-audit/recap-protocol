// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


library CLPActions{
    function mintCLP(address user, uint256 amount) external onlyContract {
        ICLP(clp).mint(user, amount);
    }

    function burnCLP(address user, uint256 amount) external onlyContract {
        ICLP(clp).burn(user, amount);
    }

    function getCLPSupply() external view returns (uint256) {
        return IERC20(clp).totalSupply();
    }
}
