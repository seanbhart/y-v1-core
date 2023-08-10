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
    // -------------------------------------------------------------------------------- \\
    // ---------- REQUIRED - storage hash tables in all Y-compatible modules ---------- \\
    // KEEP AT THE TOP OF THE MODULE
    // DO NOT CHANGE THE ORDER OF THESE VARIABLES
    // STORAGE SLOTS MUST MATCH THE Y CONTRACT
    // DATA WILL NOT BE STORED HERE (ONLY IN THE Y CONTRACT)
    mapping(address => mapping(uint256 => bytes)) public me;
    mapping(address => uint256[]) public yeetstamps;
    // --------------------------------- END REQUIRED ---------------------------------- \\
    // -------------------------------------------------------------------------------- \\

    // Optional storage hash table used to store data in the Yo contract
    // for data aggregation by data type, rather than by user (in the Y contract)
    // The first address is the user address, the second uint256 is the timestamp,
    // and the data is in the format of the data type
    mapping(address => mapping(uint256 => Yeet)) public yeets;
    // a list of all the timestamps for all users' yeets
    uint256[] public timestamps;

    struct Yeet {
        string text;
    }

    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);
    event Saved(address indexed account, uint256 indexed timestamp, Yeet data);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    /**
     * @notice Converts a string into a Yeet struct
     * @dev This function is not mandatory, and is just a convenience
     * function for this particular module
     * @param _text The string to be converted
     * @return _yeet The converted Yeet struct
     */
    function yeetize(string memory _text) public pure returns (Yeet memory _yeet) {
        return Yeet(_text);
    }

    // -------------------------------------------------------------------------------- \\
    // -------------------- REQUIRED functions for Y compatibility -------------------- \\

    /**
     * @notice Converts a string into a Yeet struct
     * @param _text The string to be converted
     * @return _yeet The converted Yeet struct
     */
    function serialize(string memory _text) public pure returns (bytes memory) {
        Yeet memory _yeet = Yeet(_text);
        return abi.encode(_yeet);
    }

    /**
     * @notice Converts a bytes memory into a Yeet struct
     * @param _data The bytes memory to be converted
     * @return _yeet The converted Yeet struct
     */
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
        me[refAddress][timestamp] = _data;
        yeetstamps[refAddress].push(timestamp);
        emit Yeeted(msg.sender, refAddress, timestamp, _data);
        return timestamp;
    }

    /**
     * @notice Should be called by the Y contract to save data in the Yo contract
     * @dev This function allows the Yo contract to store data in its own storage
     * so that it can be aggregated by data type, rather than by user
     * @param account The address of the user
     * @param _data The data to be stored
     */
    function save(address account, bytes memory _data) external {
        uint256 timestamp = block.timestamp;
        Yeet memory deserializedYeet = deserialize(_data);
        yeets[account][timestamp] = deserializedYeet;
        timestamps.push(timestamp);
        emit Saved(account, timestamp, deserializedYeet);
    }

    // --------------------------------- END REQUIRED ---------------------------------- \\
    // -------------------------------------------------------------------------------- \\

    /**
     * @dev Returns the timestamps of all the Yo yeets
     * @return The list of timestamps
     */
    function getTimestamps() public view returns (uint256[] memory) {
        return timestamps;
    }

    /**
     * @dev Allows a user to read a Yo
     * @param y The Y contract address
     * @param timestamp The timestamp of the yeet
     * @return The text of the Yo yeet
     */
    function read(address payable y, uint256 timestamp) public view returns (Yeet memory) {
        Y yContract = Y(y);
        return deserialize(yContract.me(address(this), timestamp));
    }
}
