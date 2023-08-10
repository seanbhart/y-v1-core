// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract Y {
    // the me mapping stores the saved data from module activity.
    // the address is the module address, the string is the data struct name,
    // the uint256 is the timestamp, and the bytes is the data struct.
    mapping(address => mapping(string => mapping(uint256 => bytes))) public me;

    // TODO: rename modules to branches?
    // the modules in the order to display
    address[] public modules;

    // the owners that can modify the account
    address[] public owners;

    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event ModuleInserted(address indexed module, uint256 index);
    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);

    constructor(address owner) {
        owners.push(owner);
    }

    // the Y contract needs to be able to receive ether
    // so that it can act as an account for the user
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

        // Check if the "youse" function exists on the module contract before calling it
        bytes memory youseFunctionSignature = abi.encodeWithSignature("youse()");
        (bool functionExists,) = module.staticcall(youseFunctionSignature);
        if (functionExists) {
            // Send the account address that should be associated
            // with the data that will be stored in the module
            (success, response) = module.call(
                abi.encodeWithSignature("youse(address,bytes)", msg.sender, _data)
            );
        }
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

    /**
     * @dev Allows an owner to withdraw all Ether from the contract
     */
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
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
