// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { console } from "hardhat/console.sol";
import { Yeet } from "../interfaces/logged/IYo.sol";
import { IYo } from "../interfaces/logged/IYo.sol";
import { Y } from "./Y.sol";


/**
 * @title Yo Contract
 * @dev This contract allows users to write and read text social posts (Yos) 
 * associated with their Y address and a timestamp
 * Yo hashes is stored in the Y contract, and the Yo contract is a module of the Y contract
 * The Y contract is an account / profile contract that serves as the identity of the user
 */
 contract Yo is IYo {

// |------------------------------------------------------------------------------|
// |-------------------- REQUIRED storage for Y compatibility --------------------|
// |                                                                              |
// |                                                                              |
    
    // KEEP AT THE TOP OF THE MODULE
    // DO NOT CHANGE THE ORDER OF THESE VARIABLES
    // STORAGE SLOTS MUST MATCH THE Y CONTRACT
    // DATA WILL NOT BE STORED HERE (ONLY IN THE Y CONTRACT)

    // hashes always include the block as the first value hashed,
    // followed by the data components in the order of their struct
    mapping(bytes32 => bool) public yeets;
    string private _avatar;
    string private _username;

// |                                                                              |
// |                                                                              |
// |---------------------------- END REQUIRED storage ----------------------------|
// |------------------------------------------------------------------------------|

    // The name of the module
    string public name = "Yo";

    event Saved(address indexed y, uint256 indexed timestamp, Yeet data);

    constructor() {
        console.log("Deploying a Yo contract");
    }

// |------------------------------------------------------------------------------|
// |------------------- REQUIRED functions for Y compatibility -------------------|
// |                                                                              |
// |                                                                              |

    /**
     * @notice Converts a string into a Yeet struct
     * @param _text The string to be converted
     * @return _yeet The converted Yeet struct
     */
    function serialize(string memory _text) public pure returns (bytes memory) {
        // the y will be set to the zero address
        // and the timestamp will be set to zero
        // but both will be set in the yeet function to ensure
        // the data is accurately associated with the Y contract and the block timestamp
        Yeet memory _yeet = Yeet(address(0), "", "", 0, _text);
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
     * @notice Hashes a Yeet struct and returns the hash
     * @param _yeet The Yeet struct to be hashed
     * @return The hash of the Yeet struct
     */    
    function hash(Yeet memory _yeet, uint blockNumber) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            blockNumber,
            _yeet.y,
            _yeet.username,
            _yeet.avatar,
            _yeet.timestamp,
            _yeet.text
        ));
    }

    /**
     * @notice Allows a user to write a Yo
     * @dev This function should be called by the Y contract via delegatecall so that
     * the data is emitted from the Y contract, associated with the caller
     * @param ref The address to reference
     * @param _data The data to be emitted
     * @return The updated bytes of the Yeet struct
     */
    function yeet(address ref, bytes memory _data) public returns (Yeet memory, bytes32) {
        // the address is the calling contract via delegatecall, so it is address(this)
        address y = address(this);
        uint256 timestamp = block.timestamp;
        // deserialize the data into a Yeet struct
        // so that the Y contract info and timestamp can be set
        Yeet memory deserializedYeet = deserialize(_data);
        deserializedYeet.y = y;
        deserializedYeet.username = _username;
        deserializedYeet.avatar = _avatar;
        deserializedYeet.timestamp = timestamp;
        _data = abi.encode(deserializedYeet);
        
        bytes32 hashed = hash(deserializedYeet, block.number);
        yeets[hashed] = true;

        // Use the Y contract in the event data so that the
        // Y is indexed in the log as the creator
        emit Yeeted(y, ref, timestamp, _data);
        return (deserializedYeet, hashed);
    }

    /**
     * @notice Should be called by the Y contract to save data in the Yo contract
     * @dev This function allows the Yo contract to emit data to its own logs
     * so that it can be aggregated by data type, rather than by user
     * @param _data The data to be emitted
     * @return The data that was passed
     */
    function save(bytes memory _data) external returns (bytes memory) {
        Yeet memory deserializedYeet = deserialize(_data);
        // DO NOT SAVE ANYTHING TO STORAGE - ALL STORAGE IS IN THE Y CONTRACT
        // The yeet should already have the data set before save is called
        emit Saved(deserializedYeet.y, deserializedYeet.timestamp, deserializedYeet);
        return (_data);
    }

    /**
     * @notice Deserializes an array of bytes into Yeets
     * @param _data The array of bytes to be deserialized
     * @return _yeets The array of deserialized Yeets
     */
    function deserializeAll(bytes[] memory _data) public pure returns (Yeet[] memory _yeets) {
        _yeets = new Yeet[](_data.length);
        for (uint256 i = 0; i < _data.length; i++) {
            _yeets[i] = deserialize(_data[i]);
        }
    }

    /**
     * @notice Converts a Yeet struct in bytes into a JSON string
     * @param _data The Yeet struct in bytes to be converted
     * @return _json The JSON string representation of the Yeet struct
     */
    function jsonify(bytes memory _data) public pure returns (string memory _json) {
        Yeet memory _yeet = abi.decode(_data, (Yeet));
        _json = string(abi.encodePacked(
            "{",
            "\"y\":\"", Strings.toHexString(uint256(uint160(_yeet.y))), "\",",
            "\"username\":\"", _yeet.username, "\",",
            "\"avatar\":\"", _yeet.avatar, "\",",
            "\"timestamp\":", Strings.toString(_yeet.timestamp), ",",
            "\"text\":\"", _yeet.text, "\"",
            "}"
        ));
    }

    /**
     * @notice Converts an array of Yeet structs in bytes into a JSON string
     * @param _data The array of Yeet structs in bytes to be converted
     * @return _json The JSON string representation of the Yeet structs
     */
    function jsonifyAll(bytes[] memory _data) public pure returns (string memory _json) {
        _json = "[";
        for (uint256 i = 0; i < _data.length; i++) {
            _json = string(abi.encodePacked(_json, jsonify(_data[i])));
            if (i < _data.length - 1) {
                _json = string(abi.encodePacked(_json, ","));
            }
        }
        _json = string(abi.encodePacked(_json, "]"));
    }

    /**
     * @notice Converts a serialized Yeet into a HTML string
     * @dev This allows the Yo contract to display the data in HTML format
     * in an easily embeddable way so that it can be displayed on a website
     * @param _yt The serialized Yeet (bytes) to be converted
     * @return The HTML string representation of the Yeet struct
     */
    function html(bytes memory _yt) public pure returns (string memory) {
        Yeet memory yt = deserialize(_yt);
        // string memory addressString = string(abi.encodePacked("0x", Strings.toHexString(yt.y)));
        /* solhint-disable max-line-length */
        return string(abi.encodePacked(
            "<div style=\"width: 360px; margin-top: 10px; margin-bottom: 10px; padding: 10px; font-family: Lucida Sans, sans-serif; display: flex; background-color: #111;\">",
                "<div id=\"yeet-avatar\" style=\"flex: 1; padding-right: 10px\">",
                    "<img src=\"",
                    yt.avatar,
                    "\" alt=\"avatar\" style=\"width: 64px; height: 64px; box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.1);\"/>",
                    "<div id=\"yeet-y\" style=\"color: #666; font-size: 12px; margin-top: 8px; width: 64px; display: flex; justify-content: space-between; overflow: hidden;\">",
                        "<div style=\"white-space: nowrap; overflow: hidden; text-overflow: clip; text-align: left; width: 26px;\">",
                            Strings.toHexString(yt.y),
                        "</div>",
                        "<div style=\"white-space: nowrap; overflow: show; font-size: 12px\">",
                            "...",
                        "</div>",
                        "<div style=\"white-space: nowrap; overflow: hidden; text-overflow: clip; text-align: right; direction: rtl; width: 28px;\">",
                            Strings.toHexString(yt.y),
                        "</div>",
                    "</div>",
                "</div>",
                "<div style=\"flex: 5; margin-left: 10px\">",
                    "<div style=\"display: flex; justify-content: space-between; align-items: flex-start;\">",
                        "<div>",
                            "<div id=\"yeet-username\" style=\"font-weight: bold; color: #666\">",
                                yt.username,
                            "</div>",
                        "</div>",
                        "<div id=\"yeet-timestamp\" style=\"color: #999; font-size: 12px\">",
                        Strings.toString(uint256(yt.timestamp)),
                        "</div>",
                    "</div>",
                    "<div id=\"yeet-text\" style=\"margin-top: 10px; font-size: 14px; color: #999; display: flex; justify-content: left; text-align: left;\">",
                        yt.text,
                    "</div>",
                "</div>",
            "</div>"
        ));
        /* solhint-enable max-line-length */
    }

    /**
     * @notice Returns the HTML representation of a list of yeets
     * @param _yts The list of serialized yeets (bytes) to be converted
     * @return The HTML string representation of the yeets
     */
    function feed(bytes[] memory _yts) public pure returns (string memory) {
        string memory htmlFeed = "";
        for (uint256 i = 0; i < _yts.length; i++) {
            htmlFeed = string(abi.encodePacked(htmlFeed, html(_yts[i])));
        }
        /* solhint-disable max-line-length */
        htmlFeed = string(abi.encodePacked("<div id=\"yeet-feed\" style=\"width: 360px; font-family: Arial, sans-serif; display: flex; flex-direction: column; max-width: 100% !important;\">", htmlFeed, "</div>"));
        /* solhint-enable max-line-length */
        return htmlFeed;
    }

// |                                                                              |
// |                                                                              |
// |--------------------------- END REQUIRED functions ---------------------------|
// |------------------------------------------------------------------------------|

    /**
     * @notice Converts a string into a Yeet struct
     * @dev This function is not mandatory, and is just a convenience
     * function for this particular module
     * @param _text The string to be converted
     * @return _yeet The converted Yeet struct
     */
    function yeetize(string memory _text) public pure returns (Yeet memory _yeet) {
        return Yeet({
            y: address(0),
            username: "",
            avatar: "",
            timestamp: 0,
            text: _text
        });
    }
}
