// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TaskBounty
 * @dev A contract for posting tasks with rewards, submitting solutions, and claiming bounties
 * @notice This contract is for educational purposes - allows duplicate tasks and basic bounty system
 */
contract TaskBounty {
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

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Submission) public submissions;
    mapping(uint256 => uint256[]) public taskSubmissions; // taskId => submission IDs
    mapping(address => uint256[]) public userTasks; // user => task IDs created
    mapping(address => uint256[]) public userSubmissions; // user => submission IDs

    // Events
    event TaskCreated(uint256 indexed taskId, address indexed creator, string title, uint256 reward);
    event SolutionSubmitted(
        uint256 indexed taskId, uint256 indexed submissionId, address indexed submitter, string solution
    );
    event BountyClaimed(uint256 indexed taskId, uint256 indexed submissionId, address indexed solver, uint256 reward);
    event TaskDeactivated(uint256 indexed taskId, address indexed creator);

    // Modifiers
    modifier onlyTaskCreator(uint256 _taskId) {
        require(tasks[_taskId].creator == msg.sender, "Only task creator can perform this action");
        _;
    }
}
