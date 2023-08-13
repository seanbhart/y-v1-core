// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

interface IY {
    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event ModuleInserted(address indexed module, uint256 index);
    event Yeeted(address indexed account, address indexed ref, uint256 indexed timestamp, bytes data);

    /**
     * @notice Allows a module to yeet data
     * @param module The address of the module yeeting the data
     * @param _data The data being yeeted
     * @return A boolean indicating success, and bytes of data
     */
    function yeet(address module, bytes memory _data) external returns (bool, bytes memory);

    /**
     * @notice Adds a module to the contract
     * @param module The address of the module to add
     */
    function addModule(address module) external;

    /**
     * @notice Inserts a module at a specific index in the contract
     * @param module The address of the module to insert
     * @param index The index to insert the module at
     */
    function insertModule(address module, uint256 index) external;

    /**
     * @notice Removes a module from the contract
     * @param module The address of the module to remove
     */
    function removeModule(address module) external;

    /**
     * @notice Returns the latest content from a module for a specific account
     * @param module The address of the module to retrieve content from
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content for an account
     */
    function recent(
        address module,
        uint256 earliest
    ) external view returns (bytes[] memory);

    /**
     * @notice Returns the latest content in html format from a module for a specific account
     * @param module The address of the module to retrieve content from
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content for an account in html format
     */
    function wall(
        address module,
        uint256 earliest
    ) external view returns (string memory);

    /**
     * @notice Returns the latest content from all modules for a specific account
     * @param earliest The earliest timestamp to retrieve content from
     * @return The latest content for an account from all modules in html format
     */
    function walls(uint256 earliest) external view returns (string memory);

}
