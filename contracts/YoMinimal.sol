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
    
    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);

    struct Yeet {
        string text;
    }

    // --------------------------------- END REQUIRED ---------------------------------- \\
    // -------------------------------------------------------------------------------- \\

    // -------------------------------------------------------------------------------- \\
    // -------------------- REQUIRED functions for Y compatibility -------------------- \\

    constructor() {
        console.log("Deploying a Yo contract");
    }

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
     * @dev This function could allow storage in the Yo contract, but it is not required
     * @param account The address of the user
     * @param _data The data to be stored
     * @return The data that was passed
     */
    function save(address account, bytes memory _data) external pure returns (address, bytes memory) {
        return (account, _data);
    }

    // -------------------------- END REQUIRED definitions ---------------------------- \\
    // -------------------------------------------------------------------------------- \\
}
