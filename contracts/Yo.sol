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
    struct Yeet {
        uint256 timestamp;
        string text;
    }

    event YoYeet(address indexed account, uint256 indexed timestamp, string text);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    /**
     * @dev Allows a user to write a Yo to the blockchain
     * @param y The Y contract address
     * @param text The text of the Yo
     */
    function yeet(address payable y, string memory text) public {
        Y yContract = Y(y);
        string memory structName = "Yeet";
        uint256 timestamp = block.timestamp;
        Yeet memory yt = Yeet(timestamp, text);

        // delegatecall the Y contract to pass the msg.sender as
        // owner of the Y contract (only owners are allowed to setMe)
        bytes4 functionSignature = bytes4(keccak256("setMe(string,uint256,bytes)"));
        bytes memory data = abi.encodeWithSelector(
            functionSignature,
            structName,
            timestamp,
            abi.encode(yt)
        );
        (bool success,) = address(yContract).delegatecall(data);
        require(success, "delegatecall failed");

        emit YoYeet(msg.sender, timestamp, text);
    }

    /**
     * @dev Allows a user to read a Yo from the blockchain
     * @param y The Y contract address
     * @param timestamp The timestamp of the yeet
     * @return The text of the Yo yeet
     */
    function read(address payable y, uint256 timestamp) public view returns (string memory) {
        Y yContract = Y(y);
        Yeet memory yt = abi.decode(yContract.me(address(this), "Yeet", timestamp), (Yeet));
        return yt.text;
    }
}
