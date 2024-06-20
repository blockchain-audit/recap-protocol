// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

library Events{
    event AddLiquidity(address, uint, uint, uint);
    event RemoveLiquidity(address, uint, uint, uint, uint);
    event PoolPayIn(address, string , uint, uint, uint, uint);
    event PoolPayOut(address, string, uint, uint,uint);
    event FeePaid( address, string,uint,uint,bool);
    event GovernanceUpdated(address, address);
            
}