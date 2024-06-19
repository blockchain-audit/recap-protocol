// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../state.sol";
import "../interfaces/ICLP.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library Clp {

    using SafeERC20 for IERC20;
    
    function mintCLP(State storage state,address user, uint256 amount) external  {
        ICLP(state.contractAddr.clp).mint(user, amount);
    }
    function transferIn(State storage state,address user, uint256 amount) external  {
        IERC20(state.store.currency).safeTransferFrom(user, address(this), amount);
    }
    function burnCLP(State storage state,address user, uint256 amount) external  {
        ICLP(state.contractAddr.clp).burn(user, amount);
    }

    function getCLPSupply(State storage state) external view returns (uint256) {
        return IERC20(state.contractAddr.clp).totalSupply();
    }
}

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// contract CLP is ERC20 {
//     address public store;

//     constructor(address _store) ERC20("CLP", "CLP") {
//         store = _store;
//     }

    // function mint(address to, uint256 amount) public {
    //     require(msg.sender == store, "!authorized");
    //     require(amount > 0, "!clp-amount");
    //     _mint(to, amount);
    // }

    // function burn(address from, uint256 amount) public {
    //     require(msg.sender == store, "!authorized");
    //     require(amount > 0, "!clp-amount");
    //     _burn(from, amount);
    // }
// }