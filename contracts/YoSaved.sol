// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

/**
 * @title Yo Contract
 * @dev This contract allows users to write and read text social posts (Yos) 
 * associated with their account address and a timestamp.
 * The Yos can be accessed by account address and timestamp, or by timestamp only, or by account only.
 * It also includes a function to throw an error for testing purposes.
 */
 contract Yo {
    struct YoData {
        address account;
        uint256 timestamp;
        string text;
    }

    mapping(address => uint256[]) public accountTimestamps;
    mapping(uint256 => address[]) public timestampAccounts;
    mapping(address => mapping(uint256 => YoData)) public yos;

    event YoWritten(address indexed account, uint256 indexed timestamp, string text);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    // read a specific yeet when the account and timestamp are known
    function readByAccountAndTimestamp(address account, uint256 timestamp) public view returns (YoData memory) {
        return yos[account][timestamp];
    }

    // // read all yeets when the timestamp is known
    // function readByTimestamp(uint256 timestamp) public view returns (string[] memory) {
    //     string[] memory yos = new string[](timestampAccounts[timestamp].length);
    //     for (uint i = 0; i < timestampAccounts[timestamp].length; i++) {
    //         yos[i] = timestampYos[timestamp][timestampAccounts[timestamp][i]];
    //     }
    //     return yos;
    // }

    // // read all yeets when the account is known
    // function readByAccount(address account) public view returns (string[] memory) {
    //     string[] memory _yos = new string[](accountTimestamps[account].length);
    //     for (uint i = 0; i < accountTimestamps[account].length; i++) {
    //         _yos[i] = yos[account][accountTimestamps[account][i]];
    //     }
    //     return _yos;
    // }

    function write(string memory text) public returns (uint256) {
        uint256 timestamp = block.timestamp;
        YoData memory yoData = YoData(msg.sender, timestamp, text);
        yos[msg.sender][timestamp] = yoData;
        accountTimestamps[msg.sender].push(timestamp);
        timestampAccounts[timestamp].push(msg.sender);
        return timestamp;
    }
}
// contract Yo {
//     // save by account address, then timestamp
//     mapping(address => mapping(uint256 => string)) public accountYos;
//     mapping(address => uint256[]) public accountTimestamps;

//     // save by timestamp, then account address
//     mapping(uint256 => mapping(address => string)) public timestampYos;
//     mapping(uint256 => address[]) public timestampAccounts;

//     event YoWritten(address indexed account, uint256 indexed timestamp, string text);
    
//     constructor() {
//         console.log("Deploying a Yo contract");
//     }

//     // read a specific yeet when the account and timestamp are known
//     function readByAccountAndTimestamp(address account, uint256 timestamp) public view returns (string memory) {
//         return accountYos[account][timestamp];
//     }

//     // read all yeets when the timestamp is known
//     function readByTimestamp(uint256 timestamp) public view returns (string[] memory) {
//         string[] memory yos = new string[](timestampAccounts[timestamp].length);
//         for (uint i = 0; i < timestampAccounts[timestamp].length; i++) {
//             yos[i] = timestampYos[timestamp][timestampAccounts[timestamp][i]];
//         }
//         return yos;
//     }

//     // read all yeets when the account is known
//     function readByAccount(address account) public view returns (string[] memory) {
//         string[] memory yos = new string[](accountTimestamps[account].length);
//         for (uint i = 0; i < accountTimestamps[account].length; i++) {
//             yos[i] = accountYos[account][accountTimestamps[account][i]];
//         }
//         return yos;
//     }

//     function write(string memory text) public returns (uint256) {
//         uint256 timestamp = block.timestamp;
//         accountYos[msg.sender][timestamp] = text;
//         accountTimestamps[msg.sender].push(timestamp);
//         timestampYos[timestamp][msg.sender] = text;
//         timestampAccounts[timestamp].push(msg.sender);
//         emit YoWritten(msg.sender, timestamp, text);
//         return timestamp;
//     }
// }
