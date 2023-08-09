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

    // Required storage hash table in all Y-compatible modules
    mapping(address => mapping(string => mapping(uint256 => bytes))) public me;

    event YoYeet(address indexed account, uint256 indexed timestamp, string text);
    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);
    
    constructor() {
        console.log("Deploying a Yo contract");
    }

    function serialize(string memory _text) public pure returns (bytes memory) {
        return bytes(_text);
    }

    function deserialize(bytes memory _data) public pure returns (string memory) {
        return string(_data);
    }

    function yeet(address refAddress, bytes memory _data) public payable returns (uint256) {
        uint256 timestamp = block.timestamp;
        string memory text = deserialize(_data);
        //check
        console.log("Yo timestamp: ", timestamp);
        console.log("Yo text: ", text);
        console.log("Yo refAddress: ", refAddress);

        me[refAddress]["yeet"][timestamp] = _data;
        console.log("Yo me: ", string(me[refAddress]["yeet"][timestamp]));
        emit Yeeted(msg.sender, refAddress, timestamp, _data);
        return timestamp;
    }

     /**
     * @dev Allows a user to read a Yo from the blockchain
     * @param y The Y contract address
     * @param timestamp The timestamp of the yeet
     * @return The text of the Yo yeet
     */
    function read(address payable y, uint256 timestamp) public view returns (string memory) {
        Y yContract = Y(y);
        Yeet memory yt = abi.decode(yContract.me(address(this), "yeet", timestamp), (Yeet));
        return yt.text;
    }

    // function yeet(address payable _y, string memory _text) public payable {
    //     (bool success, bytes memory data) = _y.delegatecall(
    //         abi.encodeWithSignature("setMeSimple(string)", _text)
    //     );
    //     console.log("Yo setMeSimple success: ", success);
    //     console.log("Yo setMeSimple data: ", string(data));
    // }

    /**
     * @dev Allows a user to write a Yo to the blockchain
     * @param _y The Y contract address
     * @param _text The text of the Yo
     */
    function yeetOld(address payable _y, string memory _text) public {
        // Y yContract = Y(y);
        string memory structName = "Yeet";
        uint256 timestamp = block.timestamp;
        // Yeet memory yt = Yeet(timestamp, text);
        console.log("Yo yt.structName: ", structName);
        console.log("Yo yt.text: ", _text);

        // yContract.setMe(structName, timestamp, abi.encode(yt));

        // delegatecall the Y contract to pass the msg.sender as
        // owner of the Y contract (only owners are allowed to setMe)
        // string memory functionSignature = "setMe(string,uint256,string)";
        // // bytes4 functionSignature = bytes4(keccak256("setMe(string,uint256,bytes)"));
        // bytes memory data = abi.encodeWithSignature(
        //     functionSignature,
        //     structName,
        //     timestamp,
        //     _text
        //     // bytes(_text)
        //     // abi.encode(yt)
        // );
        // console.log("Yo address(yContract): ", address(yContract));
        console.log("Yo _y: ", _y);
        // console.log("Yo data: ", string(data));
        (bool success, bytes memory responseData) = _y.delegatecall(abi.encodeWithSignature(
            "setMe2(string)",
            // structName,
            // timestamp,
            _text
            // bytes(_text)
            // abi.encode(yt)
        ));
        console.log("Yo yeet success: ", success);
        console.log("Yo yeet responseData: ", string(responseData));
        require(success, "delegatecall failed");


        emit YoYeet(msg.sender, timestamp, _text);
    }
}
