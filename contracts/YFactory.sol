// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Y } from "./Y.sol";

contract YFactory {
    event Created(address indexed y, address indexed creator);

    function create() public returns (address) {
        Y newY = new Y(msg.sender);
        emit Created(address(newY), msg.sender);
        return address(newY);
    }
}
