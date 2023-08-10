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
 contract Yo is IYo {

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

    // Optional storage hash table used to store data in the Yo contract
    // for data aggregation by data type, rather than by user (in the Y contract)
    // The first address is the user address, the second uint256 is the timestamp,
    // and the data is in the format of the data type
    mapping(address => mapping(uint256 => Yeet)) public yeets;
    // a list of all the timestamps for all users' yeets
    uint256[] public timestamps;

    event Saved(address indexed account, uint256 indexed timestamp, Yeet data);

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
     * @param ref The address to reference
     * @param _data The data to be stored
     * @return The timestamp of the yeet
     */
    function yeet(address ref, bytes memory _data) public returns (uint256) {
        uint256 timestamp = block.timestamp;
        me[ref][timestamp] = _data;
        yeetstamps[ref].push(timestamp);
        emit Yeeted(msg.sender, ref, timestamp, _data);
        return timestamp;
    }

    /**
     * @notice Should be called by the Y contract to save data in the Yo contract
     * @dev This function allows the Yo contract to store data in its own storage
     * so that it can be aggregated by data type, rather than by user
     * @param account The address of the user
     * @param _data The data to be stored
     * @return The data that was passed
     */
    function save(address account, bytes memory _data) external returns (address, bytes memory) {
        uint256 timestamp = block.timestamp;
        Yeet memory deserializedYeet = deserialize(_data);
        yeets[account][timestamp] = deserializedYeet;
        timestamps.push(timestamp);
        emit Saved(account, timestamp, deserializedYeet);
        return (account, _data);
    }

    /**
     * @notice Returns potential HTML for a yeet
     * @param account The address of the user
     * @param timestamp The timestamp of the yeet
     * @return The string HTML of the yeet
     */
    function html(address account, uint256 timestamp) public view returns (string memory) {
        Yeet memory yt = yeets[account][timestamp];
        return yeetHtml(yt);
    }

    /**
     * @notice Returns the HTML representation of a user's yeets
     * @param account The address of the user
     * @param earliest The earliest timestamp to consider for the yeets
     * @return The HTML string representation of the yeets
     */    
    function wall(address account, uint256 earliest) public view returns (string memory) {
        string memory htmlFeed = "";
        uint256[] memory accountTimestamps = yeetstamps[account];
        for (uint256 i = accountTimestamps.length; i > 0; i--) {
            uint256 timestamp = accountTimestamps[i-1];
            if (timestamp < earliest) {
                break;
            }
            Yeet memory yt = yeets[account][timestamp];
            htmlFeed = string(abi.encodePacked(htmlFeed, yeetHtml(yt)));
        }
        htmlFeed = string(abi.encodePacked("<div class=\"yeet-feed\">", htmlFeed, "</div>"));
        return htmlFeed;        
    }

    /**
     * @notice Returns the HTML representation of the most recent yeets
     * @param earliest The earliest timestamp to consider for the yeets
     * @return The HTML string representation of the yeets
     */
    function feed(uint256 earliest) public view returns (string memory) {
        string memory htmlFeed = "";
        for (uint256 i = timestamps.length; i > 0; i--) {
            uint256 timestamp = timestamps[i-1];
            if (timestamp < earliest) {
                break;
            }
            Yeet memory yt = yeets[msg.sender][timestamp];
            htmlFeed = string(abi.encodePacked(htmlFeed, yeetHtml(yt)));
        }
        htmlFeed = string(abi.encodePacked("<div class=\"yeet-feed\">", htmlFeed, "</div>"));
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
        return Yeet(_text);
    }

    /**
     * @notice Converts a Yeet struct into a HTML string
     * @dev This allows the Yo contract to display the data in HTML format
     * in an easily embeddable way so that it can be displayed on a website
     * @param yt The Yeet struct to be converted
     * @return The HTML string representation of the Yeet struct
     */
    function yeetHtml(Yeet memory yt) internal pure returns (string memory) {
        return string(abi.encodePacked(
            "<div class=\"yeet\">",
                "<div class=\"yeet-text\">",
                    yt.text,
                "</div>",
            "</div>"
        ));
    }

    /**
     * @dev Returns the Yeet struct for a given user and timestamp
     * @param account The address of the user
     * @param timestamp The timestamp of the yeet
     * @return The Yeet struct
     */
    function getYeet(address account, uint256 timestamp) public view returns (Yeet memory) {
        return yeets[account][timestamp];
    }

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
