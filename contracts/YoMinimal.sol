// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { console } from "hardhat/console.sol";
import { Yeet } from "./Structs.sol";
import { IYo } from "./interfaces/IYo.sol";
import { Y } from "./Y.sol";


/**
 * @title Yo Contract
 * @dev This contract allows users to write and read text social posts (Yos) 
 * associated with their account address and a timestamp
 * Yo data is stored in the Y contract, and the Yo contract is a module of the Y contract
 * The Y contract is an account contract that serves as the identity of the user
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
    
// |                                                                              |
// |                                                                              |
// |---------------------------- END REQUIRED storage ----------------------------|
// |------------------------------------------------------------------------------|

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
        // the account will be set to the zero address
        // and the timestamp will be set to zero
        // but both will be set in the yeet function to ensure
        // the data is accurately associated with the user account and the block timestamp
        Yeet memory _yeet = Yeet(address(0), 0, _text);
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
     * @param ref The address to reference
     * @param _data The data to be stored
     * @return The updated bytes of the Yeet struct
     */
    function yeet(address ref, bytes memory _data) public returns (Yeet memory) {
        // the address is the calling contract via delegatecall, so it is address(this)
        address account = address(this);
        uint256 timestamp = block.timestamp;
        // deserialize the data into a Yeet struct
        // so that the account and timestamp can be set
        Yeet memory deserializedYeet = deserialize(_data);
        deserializedYeet.account = account;
        deserializedYeet.timestamp = timestamp;
        _data = abi.encode(deserializedYeet);
        me[ref][timestamp] = _data;
        yeetstamps[ref].push(timestamp);
        // Use the calling account in the event data so that the
        // account is the one who is indexed in the log as the creator
        emit Yeeted(account, ref, timestamp, _data);
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
     * @notice Converts a serialized Yeet into a HTML string
     * @dev This allows the Yo contract to display the data in HTML format
     * in an easily embeddable way so that it can be displayed on a website
     * @param _yt The serialized Yeet (bytes) to be converted
     * @return The HTML string representation of the Yeet struct
     */
    function html(bytes memory _yt) public pure returns (string memory) {
        Yeet memory yt = deserialize(_yt);
        return string(abi.encodePacked(
            "<div class=\"yeet\">",
                "<div class=\"yeet-text\">",
                    yt.text,
                "</div>",
            "</div>"
        ));
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
