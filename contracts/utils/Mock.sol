// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// A Mock contract to force compilation of needed imported contracts
contract Mock is ERC721 {
    constructor() ERC721("Mock", "MOCK") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
