// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Yeet } from "../Structs.sol";

/**
 * @title Yo Interface
 * @dev This contract is the interface template for ALL Y MODULES
 * ALL Y MODULES MUST IMPLEMENT THIS INTERFACE, although they may
 * add additional functions. However, these core functions are required
 * regardless of the type of content the module manages (text, photo, etc.)
 */
interface IYo {
    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);

    /**
     * @notice Serializes a text string into bytes
     * @param _text The text string to serialize
     * @return The serialized bytes of the text string
     */
    function serialize(string memory _text) external pure returns (bytes memory);

    /**
     * @notice Deserializes bytes into a Yeet struct
     * @param _data The bytes to deserialize
     * @return The deserialized Yeet struct
     */
    function deserialize(bytes memory _data) external pure returns (Yeet memory);

    /**
     * @notice Yeets (posts) data to the contract
     * @param ref The reference address to associate with the yeet. The reference
     * will be used as a contract that contains the rules of data storage and retrieval
     * @param _data The data to yeet
     * @return The timestamp of the yeet
     */
    function yeet(address ref, bytes memory _data) external returns (uint256);

    /**
     * @notice Saves data to the contract
     * @param account The account address to associate with the data
     * @param _data The data to save
     * @return The account address and the saved data
     */
    function save(address account, bytes memory _data) external returns (address, bytes memory);

    /**
     * @notice Returns the HTML representation of a user's yeets
     * @param account The address of the user
     * @param timestamp The timestamp of the yeet to retrieve
     * @return The HTML string representation of the yeet
     */
    function html(address account, uint256 timestamp) external view returns (string memory);

    /**
     * @notice Returns the HTML representation of a user's yeets
     * @param account The address of the user
     * @param earliest The earliest timestamp to consider for the yeets
     * @return The HTML string representation of the yeets
     */
    function wall(address account, uint256 earliest) external view returns (string memory);

    /**
     * @notice Returns the HTML representation of the most recent yeets
     * @param earliest The earliest timestamp to consider for the yeets
     * @return The HTML string representation of the yeets
     */
    function feed(uint256 earliest) external view returns (string memory);

}
