// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TaskBounty
 * @dev A contract for posting tasks with rewards, submitting solutions, and claiming bounties
 * @notice This contract is for educational purposes - allows duplicate tasks and basic bounty system
 */
contract SimpleNFT { 
        struct Task {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 reward;
        bool isCompleted;
        bool isActive;
        uint256 createdAt;
        address solver;
        string solution;
        uint256 solvedAt;
    }

        struct Submission {
        uint256 taskId;
        address submitter;
        string solution;
        uint256 submittedAt;
        bool isAccepted;
    }

    // State variables
    uint256 private nextTaskId;
    uint256 private nextSubmissionId;

    // Mappings
    mapping(uint256 => Task) public tasks;
}
