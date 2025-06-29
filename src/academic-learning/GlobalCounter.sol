// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// 1. Global Counter - Anyone can increment, great for teaching state changes
contract GlobalCounter {
    // @notice The number of times this contract has been incremented
    uint256 public count;

    /**
     * @notice Increments the count by 1
     * @dev This function can be called by anyone
     */
    function increment() external {
        count++;
    }

    /**
     * @notice Returns the current count
     * @dev This function can be called by anyone
     */
    function getCount() external view returns (uint256) {
        return count;
    }
}
