// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { console } from "hardhat/console.sol";
import { Y } from "./Y.sol";

/**
 * @title Yo Contract
 * @dev This contract allows users to write and read text social posts (Yos) 
 * associated with their account address and a timestamp.
 * Yo data is stored in the Y contract, and the Yo contract is a module of the Y contract.
 * The Y contract is an account contract that serves as the identity of the user.
 */
 contract Yo {
    // Required storage hash table in all Y-compatible modules
    // DATA WILL NOT BE STORED HERE (ONLY IN THE Y CONTRACT)
    mapping(address => mapping(string => mapping(uint256 => bytes))) public me;

    struct Yeet {
        uint256 timestamp;
        string text;
    }

    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    function serialize(string memory _text) public pure returns (bytes memory) {
        return bytes(_text);
    }

    function deserialize(bytes memory _data) public pure returns (string memory) {
        // Yeet memory yt = abi.decode(_data, (Yeet));
        return string(_data);
    }

    /**
     * @notice Allows a user to write a Yo
     * @dev This function should be called by the Y contract via delegatecall so that
     * the data is stored in the Y contract, associated with the user account
     * @param refAddress The address to reference
     * @param _data The data to be stored
     * @return The timestamp of the yeet
     */
    function yeet(address refAddress, bytes memory _data) public payable returns (uint256) {
        uint256 timestamp = block.timestamp;
        me[refAddress]["yeet"][timestamp] = _data;
        emit Yeeted(msg.sender, refAddress, timestamp, _data);
        return timestamp;
    }

    /**
     * @dev Allows a user to read a Yo
     * @param y The Y contract address
     * @param timestamp The timestamp of the yeet
     * @return The text of the Yo yeet
     */
    function read(address payable y, uint256 timestamp) public view returns (string memory) {
        Y yContract = Y(y);
        return deserialize(yContract.me(address(this), "yeet", timestamp));
    }
}
