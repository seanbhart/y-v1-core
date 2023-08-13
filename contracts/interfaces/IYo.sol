// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

struct Yeet {
    address account;
    string username;
    string avatar;
    uint256 timestamp;
    string text;
}

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
     * @notice Allows a user to write a Yo
     * @dev This function should be called by the Y contract via delegatecall so that
     * the data is stored in the Y contract, associated with the user account
     * @param ref The address to reference
     * @param _data The data to be stored
     * @return The updated bytes of the Yeet struct
     */
    function yeet(address ref, bytes memory _data) external returns (Yeet memory);

    /**
     * @notice Should be called by the Y contract to save data in the Yo contract
     * @dev This function allows the Yo contract to store data in its own storage
     * so that it can be aggregated by data type, rather than by user
     * @param _data The data to be stored
     * @return The data that was passed
     */
    function save(bytes memory _data) external returns (bytes memory);

    /**
     * @notice Deserializes an array of bytes into Yeets
     * @param _data The array of bytes to be deserialized
     * @return _yeets The array of deserialized Yeets
     */
    function deserializeAll(bytes[] memory _data) external pure returns (Yeet[] memory _yeets);

    /**
     * @notice Converts a Yeet struct in bytes into a JSON string
     * @param _data The Yeet struct in bytes to be converted
     * @return _json The JSON string representation of the Yeet struct
     */
    function jsonify(bytes memory _data) external pure returns (string memory _json);

    /**
     * @notice Converts an array of Yeet structs in bytes into a JSON string
     * @param _data The array of Yeet structs in bytes to be converted
     * @return _json The JSON string representation of the Yeet structs
     */
    function jsonifyAll(bytes[] memory _data) external pure returns (string memory _json);

    /**
     * @notice Converts a serialized Yeet into a HTML string
     * @dev This allows the Yo contract to display the data in HTML format
     * in an easily embeddable way so that it can be displayed on a website
     * @param _yt The serialized Yeet (bytes) to be converted
     * @return The HTML string representation of the Yeet struct
     */
    function html(bytes memory _yt) external pure returns (string memory);

    /**
     * @notice Returns the HTML representation of a list of yeets
     * @param _yts The list of serialized yeets (bytes) to be converted
     * @return The HTML string representation of the yeets
     */
    function feed(bytes[] memory _yts) external view returns (string memory);

}
