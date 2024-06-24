// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../libraries/Liquidity.sol";

contract  LiquidityTest is Test {
    
   function setUp(){

   }
}


// // SPDX-License-Identifier: BUSL-1.1
// pragma solidity ^0.8.24;

// import "forge-std/Test.sol";
// import {State} from "src/CapStorage.sol";
// import {Liquidity} from "./Liquidity.sol";

// contract LiquidityInvariantTest is Test {
//     State public state;
//     address public user;
    
//     function setUp() public {
//         state = new State();
//         user = address(this);
//         // הגדרות נוספות כמו איזון התחלתי, CLP Supply וכו'
//     }
    
//     function invariant_poolBalanceIsNonNegative() public {
//         // נוודא שהאיזון של הבריכה לעולם לא יהיה שלילי
//         assert(state.balances.poolBalance >= 0);
//     }
    
//     function invariant_CLPSupplyIsConsistent() public {
//         // נוודא שהיחס של ה-CLP נשאר עקבי
//         uint256 balance = state.balances.poolBalance;
//         uint256 clpSupply = state.getCLPSupply();
//         uint256 calculatedCLP = state.calculateCLPAmount(balance, clpSupply, balance);
//         assert(clpSupply == calculatedCLP);
//     }
// }