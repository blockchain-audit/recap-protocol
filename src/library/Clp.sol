// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../state.sol";
import "../interfaces/ICLP.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library Clp {
    using SafeERC20 for IERC20;

    function mintCLP(State storage state, address user, uint256 amount) external {
        ICLP(state.contractAddr.clp).mint(user, amount);
    }

    function burnCLP(State storage state, address user, uint256 amount) external {
        ICLP(state.contractAddr.clp).burn(user, amount);
    }

    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.contractAddr.clp).totalSupply();
    }
}
