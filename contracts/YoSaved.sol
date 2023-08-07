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
contract YoSaved {
    struct Yeet {
        uint256 timestamp;
        string text;
    }

    uint256[] public timestamps;
    mapping(uint256 => address[]) public yeets;

    event YoYeet(address indexed account, uint256 indexed timestamp, string text);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    /**
     * @dev Allows a user to write a Yo to the blockchain
     * @param y The Y contract address
     * @param text The text of the Yo
     */
    function yeet(address y, string memory text) public {
        // get the Y contract
        Y yContract = Y(y);
        // get the account address
        address account = msg.sender;
        // get the timestamp
        uint256 timestamp = block.timestamp;
        // create the yeet
        Yeet memory yt = Yeet(timestamp, text);
        // store the yeet in the Y contract
        yContract.setMe(account, address(this), "Yeet", timestamp, abi.encode(yt));
        // store the timestamp used and add the account to the list of accounts for the timestamp
        timestamps.push(timestamp);
        yeets[timestamp].push(account);
        // emit the YoYeet event
        emit YoYeet(account, timestamp, text);
    }

    /**
     * @dev Allows a user to read a Yo from the blockchain
     * @param y The Y contract address
     * @param timestamp The timestamp of the yeet
     * @return The text of the Yo yeet
     */
    function read(address y, uint256 timestamp) public view returns (string memory) {
        // get the Y contract
        Y yContract = Y(y);
        // get the yeet from the Y contract
        Yeet memory yt = abi.decode(yContract.me(address(this), "Yeet", timestamp), (Yeet));
        // return the text of the yeet
        return yt.text;
    }

    // Get a list of all addresses associated with a timestamp
    function getAddresses(uint256 timestamp) public view returns (address[] memory) {
        return yeets[timestamp];
    }
}
