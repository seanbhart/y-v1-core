// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { console } from "hardhat/console.sol";
import { IYo } from "./interfaces/IYo.sol";
import { IY } from "./interfaces/IY.sol";

contract Y is IY {

// |------------------------------------------------------------------------------|
// |--------------------------- REQUIRED storage ORDER ---------------------------|
// |                                                                              |
    
    // KEEP AT THE TOP OF THE Y CONTRACT
    // DO NOT CHANGE THE ORDER OF THESE VARIABLES
    // OTHERWISE MODULE STORAGE SLOTS WILL NOT MATCH
    // Module: e.g. Yo Contract

    // the "me" mapping stores the saved data from module activity
    // the address is the MODULE address, the string is the data struct name,
    // the uint256 is the timestamp, and the bytes is the data struct
    mapping(address => mapping(uint256 => bytes)) public me;
    // a list of all the timestamps for a user's yeets
    // the logic follows the "me" mapping - address is the MODULE address
    mapping(address => uint256[]) public yeetstamps;
    // The avatar is a string that represents the IPFS hash of the user's avatar
    string private _avatar;
    string private _username;

// |                                                                              |
// |------------------------ END REQUIRED storage ORDER --------------------------|
// |------------------------------------------------------------------------------|

// |------------------------------------------------------------------------------|
// |------------- The following variables and functions are generally ------------|
// |----------------- needed to be compatible with most modules ------------------|
// |                                                                              |
    string private _bio;

    // TODO: rename modules to branches?
    // the modules in the order to display
    address[] public modules;

    // the owners that can modify protected data
    address[] public owners;

    constructor(address owner) {
        owners.push(owner);
    }

    // the Y contract needs to be able to receive ether
    // so that it can act as an account for the user, if desired
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    /**
     * @notice The generalized delegatecall function for the Y contract
     * @dev Allows the owner to utilize any module in a standardized way
     * @param module The address of the module to delegate the call to
     * @param _data The data to be sent with the delegate call
     */    
    function yeet(address module, bytes memory _data) public onlyOwner returns (bool success, bytes memory response) {
        (success, response) = module.delegatecall(
            abi.encodeWithSignature("yeet(address,bytes)", module, _data)
        );

        // The module will have a "save" function that may or may not have
        // functionality - call it anyway and pass the data for use if needed
        IYo(module).save(response);
    }

    /**
     * @notice Returns the yeetstamps (timestamps) for a given module for this Y
     * @param module The address of the module
     * @return An array of timestamps
     */
    function getYeetstamps(address module) public view returns (uint256[] memory) {
        return yeetstamps[module];
    }

    /**
     * PROFILE INFO
     */

    /**
     * @notice Returns the username for the profile
     * @dev Anyone can retrieve the username for the profile
     * @return The username
     */
    function username() public view virtual returns (string memory) {
        return _username;
    }

    /**
     * @notice Sets the username for the profile
     * @dev Allows the owner to set a username for their profile
     * @param _newUsername The desired username
     */
    function setUsername(string memory _newUsername) public onlyOwner {
        _username = _newUsername;
    }

    /**
     * @notice Returns the bio for the profile
     * @dev Anyone can retrieve the bio for the profile
     * @return The bio
     */
    function bio() public view virtual returns (string memory) {
        return _bio;
    }

    /**
     * @notice Sets the bio for the profile
     * @dev Allows the owner to set a bio for their profile
     * @param _newBio The desired bio
     */
    function setBio(string memory _newBio) public onlyOwner {
        _bio = _newBio;
    }

    /**
     * @notice Returns the avatar for the profile
     * @dev Anyone can retrieve the avatar for the profile
     * @return The avatar hash
     */
    function avatar() public view virtual returns (string memory) {
        return _avatar;
    }

    /**
     * @notice Returns the avatar for the profile
     * @dev Anyone can retrieve the avatar for the profile
     * @return The avatar
     */
     function avatarURI() public view virtual returns (string memory) {
        // string memory baseURI = _baseURI();
        // return bytes(baseURI).length > 0 ? string.concat(baseURI, _avatar) : "";
        return _avatar;
    }

    /**
     * @dev Base URI for computing {avatarURI}. If set, the resulting URI for
     * the avatar will be the concatenation of the `baseURI` and the `avatar`
     * which is the IPFS hash of the user's avatar
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    // /**
    //  * @notice Sets the avatar for the profile
    //  * @dev Allows the owner to set the avatar for their profile
    //  * @param _newAvatarIpfsHash The desired avatar IPFS hash
    //  */
    // function setAvatar(string memory _newAvatarIpfsHash) public onlyOwner {
    //     _avatar = _newAvatarIpfsHash;
    // }

    /**
     * @notice Sets the avatar for the profile
     * @dev Allows the owner to set the avatar for their profile as an NFT they own
     * @param nftContract The address of the NFT contract
     * @param tokenId The ID of the NFT
     */
    function setAvatar(address nftContract, uint256 tokenId) public onlyOwner {
        // Check if the caller owns the NFT
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender, "Caller does not own the NFT");

        // Get the token URI and set it as the avatar
        string memory tokenURI = IERC721Metadata(nftContract).tokenURI(tokenId);
        _avatar = tokenURI;
    }

    /**
     * MODULES
    */

    /**
     * @notice Returns the list of modules
     * @dev Retrieves the array of added modules for this Y
     * @return An array of module addresses
     */
    function getModules() public view returns (address[] memory) {
        return modules;
    }

    /**
     * @dev Adds a new module to the modules array
     * @param module The address of the module to be added
     */
    function addModule(address module) public onlyOwner preventDelegateCall {
        // abort if module is already in the array
        for (uint256 i = 0; i < modules.length; i++) {
            if (modules[i] == module) {
                return;
            }
        }
        modules.push(module);
        emit ModuleAdded(module);
    }

    /**
     * @dev Inserts a new module into the modules array at the specified index
     * @param module The address of the module to be inserted
     * @param index The index at which the module should be inserted
     */
    function insertModule(address module, uint256 index) public onlyOwner preventDelegateCall {
        // if the index is greater than the length of the array
        // then just push the module to the end
        if (index >= modules.length) {
            modules.push(module);
        } else {
            // otherwise, we need to insert the module at the index
            // first, we need to push a zero address to the end of the array
            modules.push(address(0));
            // then we need to shift all the modules after the index
            // to the right by one
            for (uint256 i = modules.length - 1; i > index; i--) {
                modules[i] = modules[i - 1];
            }
            modules[index] = module;
        }

        emit ModuleInserted(module, index);
    }

    /**
     * @dev Removes a module from the modules array
     * @param module The address of the module to be removed
     */    
    function removeModule(address module) public onlyOwner preventDelegateCall {
        for (uint256 i = 0; i < modules.length; i++) {
            if (modules[i] == module) {
                // loop through the modules array again
                // and shift all the modules after the index
                // to the left by one
                for (uint256 j = i; j < modules.length - 1; j++) {
                    modules[j] = modules[j + 1];
                }
                modules.pop();
                break;
            }
        }

        emit ModuleRemoved(module);
    }

    /**
     * AGGREGATORS
    */

    /**
     * @notice Returns the latest content from a module for a specific Y
     * @param module The address of the module to retrieve content from
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content for a Y
     */
    function recentBytes(
        address module,
        uint256 earliest
    ) public view returns (bytes[] memory) {
        // Get all the timestamps for the Y for the passed module
        uint256[] memory timestamps = getYeetstamps(module);
        if (timestamps.length == 0) {
            return new bytes[](0);
        }

        // filter out the timestamps that are earlier than the earliest
        // this is done by creating a new array and pushing the timestamps
        // that are later than the earliest
        uint256[] memory _latestTimestamps = new uint256[](timestamps.length);
        uint256 count = 0;
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (timestamps[i] >= earliest) {
                _latestTimestamps[count] = timestamps[i];
                count++;
            }
        }

        // The appropriate Yeets will be in the me hash table,
        // accessible via the module and timestamp - they will
        // be serialized structs and can be decoded via the module
        bytes[] memory _yts = new bytes[](_latestTimestamps.length);
        for (uint256 i = 0; i < _latestTimestamps.length; i++) {
            _yts[i] = me[module][_latestTimestamps[i]];
        }
        return _yts;
    }

    /**
     * @notice Returns the latest content from a module for a specific Y in JSON format
     * @param module The address of the module to retrieve content from
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content in JSON format
     */
    function recentJson(
        address module,
        uint256 earliest
    ) public view returns (string memory) {
        // Get the recent bytes
        bytes[] memory recent = recentBytes(module, earliest);

        // Use IYo to jsonify the bytes
        return IYo(module).jsonifyAll(recent);
    }

    /**
     * HTML GENERATORS
    */

    /**
     * @notice Returns the latest content in html format from a module for a specific Y
     * @param module The address of the module to retrieve content from
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content in html format
     */
    function wall(
        address module,
        uint256 earliest
    ) public view returns (string memory) {
        // Get all the timestamps for the Y for the passed module
        uint256[] memory timestamps = getYeetstamps(module);
        if (timestamps.length == 0) {
            return "";
        }

        // filter out the timestamps that are earlier than the earliest
        // this is done by creating a new array and pushing the timestamps
        // that are later than the earliest
        uint256[] memory _latestTimestamps = new uint256[](timestamps.length);
        uint256 count = 0;
        for (uint256 i = 0; i < timestamps.length; i++) {
            if (timestamps[i] >= earliest) {
                _latestTimestamps[count] = timestamps[i];
                count++;
            }
        }

        // The appropriate Yeets will be in the me hash table,
        // accessible via the module and timestamp - they will
        // be serialized structs and can be decoded via the module
        bytes[] memory _yts = new bytes[](_latestTimestamps.length);
        for (uint256 i = 0; i < _latestTimestamps.length; i++) {
            _yts[i] = me[module][_latestTimestamps[i]];
        }
        return IYo(module).feed(_yts);
    }

    /**
     * @notice Returns the latest content from all modules for a specific Y
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content from all modules in html format
     */
    function walls(uint256 earliest) public view returns (string memory) {
        string memory html = "";
        if (modules.length == 0) {
            return "no modules";
        }
        for (uint256 i = 0; i < modules.length; i++) {
            html = string(abi.encodePacked(html, wall(modules[i], earliest)));
        }
        return html;
    }


    /**
     * HELPERS
    */

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        //directly from an EOA owner, or through the Y itself (which gets redirected through execute())
        bool _isOwner = false;
        for (uint i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                _isOwner = true;
                break;
            }
        }
        require(_isOwner || msg.sender == address(this), "only owner");
    }

    /**
     * @dev Allows an owner to withdraw all Ether from the contract
     */
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    /**
     * @dev Allows an owner to add a new owner to the owners array
     * @param newOwner The address of the new owner
     */
    function addOwner(address newOwner) public onlyOwner {
        owners.push(newOwner);
    }

    /**
     * @notice Removes an owner from the owners array
     * @dev Allows an owner to remove an owner from the owners array
     * @param owner The address of the owner to be removed
     */
    function removeOwner(address owner) public onlyOwner {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }
    }

    /**
     * @notice Replaces an existing owner with a new owner
     * @dev Allows the owner to replace an existing owner with a new owner
     * @param oldOwner The address of the owner to be replaced
     * @param newOwner The address of the new owner
     */    
    function replaceOwner(address oldOwner, address newOwner) public onlyOwner {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == oldOwner) {
                owners[i] = newOwner;
                break;
            }
        }
    }

    /**
     * @dev Checks if the passed address is an owner
     * @param sender The address to check
     */
    function isOwner(address sender) public view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (sender == owners[i]) {
                return true;
            }
        }
        return false;
    }

    modifier preventDelegateCall() {
        require(msg.sender == tx.origin, "delegatecall not allowed");
        _;
    }
}
