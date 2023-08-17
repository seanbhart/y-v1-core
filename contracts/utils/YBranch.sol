// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.4;

import { console } from "hardhat/console.sol";

contract YBranch {
    struct Branch {
        address addr;
        uint[] branchIds;
    }

    Branch[] public branches;

    /**
     * @dev Creates a new branch with the given contract address
     * @param _addr the address of the contract to add as a branch
     * @return the ID of the newly created branch
     */
    function createBranch(address _addr) public returns (uint) {
        Branch memory newBranch = Branch(_addr, new uint[](0));
        branches.push(newBranch);
        return branches.length - 1;
    }

    /**
     * @dev Adds a contract to a parent branch as a child branch
     * @param _parentId the ID of the parent branch
     * @param _branchAddr the address of the contract to be added
     * @return the ID of the newly created child branch
     */
    function addChildBranch(uint _parentId, address _branchAddr) public returns (uint) {
        require(_parentId < branches.length, "Parent ID out of bounds");
        uint childId = createBranch(_branchAddr);
        branches[_parentId].branchIds.push(childId);
        return childId;
    }

    /**
     * @dev Reorders child branches when one is inserted or deleted
     * @param _parentId the ID of the parent branch
     * @param _childId the ID of the child branch
     */
    function reorderChildBranches(uint _parentId, uint _childId) private {
        require(_parentId < branches.length, "Parent ID out of bounds");
        require(_childId < branches.length, "Child ID out of bounds");
        uint[] memory branchIds = branches[_parentId].branchIds;
        uint[] memory newBranchIds = new uint[](branchIds.length + 1);
        uint i = 0;
        for (; i < branchIds.length; i++) {
            if (branchIds[i] == _childId) {
                break;
            }
            newBranchIds[i] = branchIds[i];
        }
        newBranchIds[i] = _childId;
        for (; i < branchIds.length; i++) {
            newBranchIds[i + 1] = branchIds[i];
        }
        branches[_parentId].branchIds = newBranchIds;
    }

    /**
     * @dev Deletes a branch
     * @param _branchId the ID of the branch to delete
     */
    function deleteBranch(uint _branchId) public {
        require(_branchId < branches.length, "Branch ID out of bounds");
        delete branches[_branchId];
    }

    /**
     * @dev Retrieves the address of a specific branch
     * @param _branchId the ID of the branch
     * @return the address of the branch
     */
    function getBranchAddress(uint _branchId) public view returns (address) {
        require(_branchId < branches.length, "Branch ID out of bounds");
        return branches[_branchId].addr;
    }

    /**
     * @dev Retrieves the IDs of child branches for a specific parent branch
     * @param _branchId the ID of the parent branch
     * @return an array of IDs of the child branches
     */
    function getBranchIds(uint _branchId) public view returns (uint[] memory) {
        require(_branchId < branches.length, "Branch ID out of bounds");
        return branches[_branchId].branchIds;
    }

    /**
     * @dev Retrieves the number of branches
     * @return the number of branches
     */
    function getBranchCount() public view returns (uint) {
        return branches.length;
    }
}
