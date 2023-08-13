// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { Y } from "./Y.sol";

contract YFactory {
    // a list of created Y contracts for each creator
    mapping(address => address[]) public mY;
    address[] public allY;

    event Created(address indexed y, address indexed creator);

    /**
     * @dev Creates a new Y contract and stores the address in the mapping
     * @return The address of the newly created Y contract
     */
    function create() public returns (address) {
        Y newY = new Y(msg.sender);
        mY[msg.sender].push(address(newY));
        allY.push(address(newY));
        emit Created(address(newY), msg.sender);
        return address(newY);
    }

    /**
     * @dev Returns the addresses of all Y contracts created by a specific creator
     * @param creator The address of the creator
     * @return An array of addresses of Y contracts created by the creator
     */
    function getYs(address creator)
        public
        view
        returns (address[] memory)
    {
        return mY[creator];
    }

    /**
     * @dev Returns the addresses of all Y contracts created by the caller
     * @return An array of addresses of Y contracts created by the caller
     */
    function getMy() public view returns (address[] memory) {
        return mY[msg.sender];
    }
}
