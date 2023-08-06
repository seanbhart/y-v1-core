// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract Y {
    // the me mapping stores the saved data from module
    // activity. the address is the module address, the
    // string is the data key, and the bytes is the data
    // the rules around module names and data types are
    // defined by the module itself
    mapping(address => mapping(string => bytes)) public me;

    // the modules mapping stores the addresses of modules that
    // have been added to the account and if they are active
    mapping(address => bool) public modules;
}
