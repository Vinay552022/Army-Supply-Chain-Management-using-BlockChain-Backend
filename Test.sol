// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;
contract getTimeStamp{
    function ts()public view returns(uint){
        return block.timestamp;
    }
}