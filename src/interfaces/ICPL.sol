pragma solidity ^0.8.24;

interface ICLP {
    function burn(address from, uint256 amount) external;

    function mint(address to, uint256 amount) external;   
}
