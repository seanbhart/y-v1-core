// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";
import { Yeet as YoYeet } from "../interfaces/stored/IYo.sol";
import { Yo } from "../stored/Yo.sol";

/**
 * @title Yeet Contract
 * @dev This is a test contract for general Yeet functions and gas cost analysis
 */
 contract Yeet {

    // hashes always include the block as the first value hashed,
    // followed by the data components in the order of their struct
    mapping(bytes32 => bool) public yeets;

    event LogBytes(bytes value);
    event LogUint(uint256 value);
    event LogString(string value);
    event LogYoYeet(YoYeet value);

    function findYeet(bytes32 hash) public view returns (bool) {
        return yeets[hash];
    }

    function logBytes(bytes memory value) public returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(block.number, value));
        yeets[hash] = true;
        emit LogBytes(value);
        return hash;
    }

    function logUint(uint256 value) public returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(block.number, value));
        yeets[hash] = true;
        emit LogUint(value);
        return hash;
    }

    function logString(string memory value) public returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(block.number, value));
        yeets[hash] = true;
        emit LogString(value);
        return hash;
    }

    function logYoYeet(string memory text) public returns (bytes32) {
        YoYeet memory yeet = yeetize(text);
        bytes32 hash = hashYeet(yeet);
        yeets[hash] = true;
        emit LogYoYeet(yeet);
        return hash;
    }

    function logYoYeetExpensive(string memory text) public returns (bytes32) {
        YoYeet memory yeet = yeetize(text);
        bytes32 hash = hashYeetExpensive(yeet);
        yeets[hash] = true;
        emit LogYoYeet(yeet);
        return hash;
    }

    /* solhint-disable max-line-length */

    function yeetize(string memory _text) public view returns (YoYeet memory _yeet) {
        return YoYeet({
            y: address(this),
            username: "seanhart.eth",
            avatar: "data:application/json;base64,eyJuYW1lIjogImJhZGdlciAxIiwgImRlc2NyaXB0aW9uIjogImtlZXBlciBvZiB0aGUgYmxvY2tjaGFpbiBmb3Jlc3QiLCAiaW1hZ2UiOiAiaXBmczovL1FtY25zZVRYWnFWYWg4RHAxSHBZaERwWUxmRm1lWFg4cXk1MzhoanNnWGh6VWsvU2NyZWVuc2hvdCUyMDIwMjMtMDctMTklMjBhdCUyMDEyLjUxLjAyLnBuZyIsICJwcm9wZXJ0aWVzIjogeyJudW1iZXIiOiAxLCAibmFtZSI6ICJiYWRnZXIifX0=",
            timestamp: block.timestamp,
            text: _text
        });
    }

    function hashYeet(YoYeet memory _yeet) public view returns (bytes32) {
        return keccak256(abi.encodePacked(block.number, _yeet.y, _yeet.username, _yeet.avatar, _yeet.timestamp, _yeet.text));
    }

    function hashYeetExpensive(YoYeet memory _yeet) public view returns (bytes32) {
        return keccak256(abi.encodePacked(block.number, keccak256(abi.encodePacked(_yeet.y, _yeet.username, _yeet.avatar, _yeet.timestamp, _yeet.text))));
    }

    /* solhint-enable max-line-length */
}
