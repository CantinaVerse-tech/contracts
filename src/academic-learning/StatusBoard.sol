// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract StatusBoard {
    mapping(address => bytes32) public statuses;

    function updateStatus(bytes32 status) external {
        statuses[msg.sender] = status;
    }

    function getStatus(address user) external view returns (bytes32) {
        return statuses[user];
    }
}
