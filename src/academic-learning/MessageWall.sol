// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract MessageWall {
    mapping(address => mapping(address => bytes32)) public messages;

    /**
     * @notice Allows a user to leave a message for another user.
     * @param recipient The address of the user to receive the message.
     * @param message The message to be sent, hashed for privacy.
     * @dev The message is stored in a mapping where the sender's address maps to the recipient's address.
     */
    function leaveMessage(address recipient, bytes32 message) external {
        messages[msg.sender][recipient] = message;
    }

    /**
     * @notice Allows a user to read a message from another user.
     * @param sender The address of the user who sent the message.
     * @dev The message is retrieved from the mapping and returned.
     */
    function readMessage(address sender) external view returns (bytes32) {
        return messages[sender][msg.sender];
    }
}
