// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract Y {

    // the owners that can modify the account
    address[] public owners;

    // the me mapping stores the saved data from module activity.
    // the address is the module address, the string is the data struct name,
    // the uint256 is the timestamp, and the bytes is the data struct.
    mapping(address => mapping(string => mapping(uint256 => bytes))) public me;

    // TODO: rename modules to branches?
    // the modules in the order to display
    address[] public modules;

    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event ModuleInserted(address indexed module, uint256 index);

    // // solhint-disable-next-line no-empty-blocks
    // receive() external payable {}

    constructor(address owner) {
        owners.push(owner);
    }

    /**
     * @dev Executes a transaction from the Y contract
     * @param structName The name of the struct format of the data
     * @param timestamp The timestamp of the data
     * @param value The value of the data to be stored
     */
    function setMe(string memory structName, uint256 timestamp, bytes memory value) public onlyOwner {
        // the caller can only set its own data (and must be the owner of the Y contract)
        // although the owner can delegatecall from a module to set the data for the module
        me[tx.origin][structName][timestamp] = value;
    }

    /**
     * @dev Adds a new module to the modules array
     * @param module The address of the module to be added
     */
    function addModule(address module) public onlyOwner preventDelegateCall {
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
     * HELPERS
    */

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        //directly from an EOA owner, or through the account itself (which gets redirected through execute())
        bool _isOwner = false;
        for (uint i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                _isOwner = true;
                break;
            }
        }
        require(_isOwner || msg.sender == address(this), "only owner");
    }

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
