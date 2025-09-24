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

    modifier taskExists(uint256 _taskId) {
        require(_taskId < nextTaskId, "Task does not exist");
        _;
    }

    modifier taskActive(uint256 _taskId) {
        require(tasks[_taskId].isActive, "Task is not active");
        require(!tasks[_taskId].isCompleted, "Task is already completed");
        _;
    }

    modifier submissionExists(uint256 _submissionId) {
        require(_submissionId < nextSubmissionId, "Submission does not exist");
        _;
    }

    /**
     * @dev Create a new task with reward
     * @param _title Title of the task
     * @param _description Detailed description of the task
     * @notice Reward is sent with the transaction (msg.value). Accepts 0 or greater.
     */
    function createTask(string calldata _title, string calldata _description) external payable {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");

        uint256 taskId = nextTaskId++;

        tasks[taskId] = Task({
            id: taskId,
            creator: msg.sender,
            title: _title,
            description: _description,
            reward: msg.value,
            isCompleted: false,
            isActive: true,
            createdAt: block.timestamp,
            solver: address(0),
            solution: "",
            solvedAt: 0
        });

        userTasks[msg.sender].push(taskId);

        emit TaskCreated(taskId, msg.sender, _title, msg.value);
    }

    function submitSolution(uint256 _taskId, string calldata _solution)
        external
        taskExists(_taskId)
        taskActive(_taskId)
    {
        require(bytes(_solution).length > 0, "Solution cannot be empty");
        require(msg.sender != tasks[_taskId].creator, "Task creator cannot submit solution");

        uint256 submissionId = nextSubmissionId++;

        submissions[submissionId] = Submission({
            taskId: _taskId,
            submitter: msg.sender,
            solution: _solution,
            submittedAt: block.timestamp,
            isAccepted: false
        });

        taskSubmissions[_taskId].push(submissionId);
        userSubmissions[msg.sender].push(submissionId);

        emit SolutionSubmitted(_taskId, submissionId, msg.sender, _solution);
    }
}
