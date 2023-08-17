// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { console } from "hardhat/console.sol";
import { Yeet } from "../interfaces/stored/IYo.sol";
import { IYo } from "../interfaces/stored/IYo.sol";
import { Y } from "./Y.sol";


/**
 * @title Yo Contract
 * @dev This contract allows users to write and read text social posts (Yos) 
 * associated with their Y address and a timestamp
 * Yo data is stored in the Y contract, and the Yo contract is a module of the Y contract
 * The Y contract is an account / profile contract that serves as the identity of the user
 */
 contract YoMinimal is IYo {

// |------------------------------------------------------------------------------|
// |-------------------- REQUIRED storage for Y compatibility --------------------|
// |                                                                              |
// |                                                                              |
    
    // KEEP AT THE TOP OF THE MODULE
    // DO NOT CHANGE THE ORDER OF THESE VARIABLES
    // STORAGE SLOTS MUST MATCH THE Y CONTRACT
    // DATA WILL NOT BE STORED HERE (ONLY IN THE Y CONTRACT)
    mapping(address => mapping(uint256 => bytes)) public me;
    mapping(address => uint256[]) public yeetstamps;
    string private _avatar;
    string private _username;

// |                                                                              |
// |                                                                              |
// |---------------------------- END REQUIRED storage ----------------------------|
// |------------------------------------------------------------------------------|

    // Highly recommended to include a name for the module
    string public name = "Yo";

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
     * @notice Allows a user to write a Yo
     * @dev This function should be called by the Y contract via delegatecall so that
     * the data is stored in the Y contract
     * @param ref The address to reference
     * @param _data The data to be stored
     * @return The updated bytes of the Yeet struct
     */
    function yeet(address ref, bytes memory _data) public returns (Yeet memory) {
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
        me[ref][timestamp] = _data;
        yeetstamps[ref].push(timestamp);
        // Use the calling Y in the event data so that the
        // Y contract is the one who is indexed in the log as the creator
        emit Yeeted(y, ref, timestamp, _data);
        return deserializedYeet;
    }

    /**
     * @notice Should be called by the Y contract to save data in the Yo contract
     * @dev This function allows the Yo contract to store data in its own storage
     * so that it can be aggregated by data type, rather than by user
     * @param _data The data to be stored
     * @return The data that was passed
     */
    function save(bytes memory _data) external pure returns (bytes memory) {
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
        /* solhint-disable max-line-length */
        return string(abi.encodePacked(
            "<div style=\"width: 360px; margin-top: 10px; margin-bottom: 10px; padding: 10px; font-family: Lucida Sans, sans-serif; display: flex; background-color: #111;\">",
                "<div style=\"flex: 1; padding-right: 10px\">",
                    "<img src=\"https://placekitten.com/48/48\" alt=\"Profile Picture\" style=\"width: 64px; height: 64px; box-shadow: 0px 4px 4px rgba(0, 0, 0, 0.1);\"/>",
                    "<div style=\"color: #666; font-size: 12px; margin-top: 8px; width: 64px; display: flex; justify-content: space-between; overflow: hidden;\">",
                        "<div style=\"white-space: nowrap; overflow: hidden; text-overflow: clip; text-align: left; width: 26px;\">",
                            "0xF863B06A73845d19F0972af747358F60d80A442C",
                        "</div>",
                        "<div style=\"white-space: nowrap; overflow: show; font-size: 12px\">",
                            "...",
                        "</div>",
                        "<div style=\"white-space: nowrap; overflow: hidden; text-overflow: clip; text-align: right; direction: rtl; width: 28px;\">",
                            "0xF863B06A73845d19F0972af747358F60d80A442C",
                        "</div>",
                    "</div>",
                "</div>",
                "<div style=\"flex: 5; margin-left: 10px\">",
                    "<div style=\"display: flex; justify-content: space-between; align-items: flex-start;\">",
                        "<div>",
                            "<div style=\"font-weight: bold; color: #666\">",
                                "randomerror.eth",
                            "</div>",
                        "</div>",
                        "<div id=\"yeet-timestamp\" style=\"color: #999; font-size: 12px\">",
                        yt.timestamp,
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
        htmlFeed = string(abi.encodePacked("<div class=\"yeet-feed\">", htmlFeed, "</div>"));
        return htmlFeed;
    }

// |                                                                              |
// |                                                                              |
// |--------------------------- END REQUIRED functions ---------------------------|
// |------------------------------------------------------------------------------|

}
