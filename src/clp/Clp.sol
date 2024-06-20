// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {stateClp} from "src/clp/clpStorage.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract CLP is ERC20 {

    stateClp c;
    

    constructor(address _store) ERC20("CLP", "CLP") {
        c.store = _store;
    }

    function mint(address to, uint256 amount) public {
        require(msg.sender == c.store, "!authorized");
        require(amount > 0, "!clp-amount");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        require(msg.sender == c.store, "!authorized");
        require(amount > 0, "!clp-amount");
        _burn(from, amount);
    }
}
