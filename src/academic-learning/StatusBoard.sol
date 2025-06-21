// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract StatusBoard {
    mapping(address => bytes32) public statuses;

    /**
     * @notice Updates the status of the sender.
     * @param status The status to set
     * @dev Only the sender can update their status
     */
    function updateStatus(bytes32 status) external {
        statuses[msg.sender] = status;
    }

    /**
     * @notice Returns the status of the user
     * @param user The user to get the status of
     * @return The status of the user
     */
    function getStatus(address user) external view returns (bytes32) {
        return statuses[user];
    }
}
