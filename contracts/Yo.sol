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

    // Optional storage hash table used to store data in the Yo contract
    // for data aggregation by data type, rather than by user (in the Y contract)
    // The first address is the user address, the second uint256 is the timestamp,
    // and the data is in the format of the data type
    mapping(address => mapping(uint256 => Yeet)) public yeets;

    struct Yeet {
        // uint256 timestamp;
        string text;
    }

    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);
    event Yoused(address indexed account, uint256 indexed timestamp, Yeet data);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    function yeetize(string memory _text) public pure returns (Yeet memory _yeet) {
        return Yeet(_text);
    }

    function serialize(string memory _text) public pure returns (bytes memory) {
        Yeet memory _yeet = Yeet(_text);
        return abi.encode(_yeet);
    }

    function deserialize(bytes memory _data) public pure returns (Yeet memory _yeet) {
        _yeet = abi.decode(_data, (Yeet));
    }

    /**
     * @notice Allows a user to write a Yo
     * @dev This function should be called by the Y contract via delegatecall so that
     * the data is stored in the Y contract, associated with the user account
     * @param refAddress The address to reference
     * @param _data The data to be stored
     * @return The timestamp of the yeet
     */
    function yeet(address refAddress, bytes memory _data) public returns (uint256) {
        uint256 timestamp = block.timestamp;
        me[refAddress]["yeet"][timestamp] = _data;
        emit Yeeted(msg.sender, refAddress, timestamp, _data);
        return timestamp;
    }

    function youse(address account, bytes memory _data) public {
        uint256 timestamp = block.timestamp;
        Yeet memory deserializedYeet = deserialize(_data);
        yeets[account][timestamp] = deserializedYeet;
        emit Yoused(account, timestamp, deserializedYeet);
    }

    /**
     * @dev Allows a user to read a Yo
     * @param y The Y contract address
     * @param timestamp The timestamp of the yeet
     * @return The text of the Yo yeet
     */
    function read(address payable y, uint256 timestamp) public view returns (Yeet memory) {
        Y yContract = Y(y);
        return deserialize(yContract.me(address(this), "yeet", timestamp));
    }
}
