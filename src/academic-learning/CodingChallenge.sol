// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title CodingChallenge
 * @author CantinaVerse-Tech
 * @dev A smart contract for managing coding challenges with automated test case validation
 * @notice This contract allows instructors to create coding challenges and students to submit solutions
 */
contract CodingChallenge {
    /// @notice The title of the coding challenge
    /// @dev Publicly accessible string containing the challenge name
    string public challengeTitle;

    /// @notice Detailed description of the coding challenge
    /// @dev Contains the problem statement and context for students
    string public description;

    /// @notice Requirements and constraints for the challenge
    /// @dev Lists specific requirements that solutions must meet
    string public requirements;

    /// @notice Array of hashed expected outputs for test cases
    /// @dev Each hash represents the keccak256 of an expected output string
    bytes32[] public testCaseHashes;

    /// @notice Mapping of student addresses to their submission hashes
    /// @dev Maps student address to array of hashed outputs from their latest submission
    mapping(address => bytes32[]) public studentSubmissions;

    /// @notice Mapping to track which students have completed the challenge
    /// @dev Maps student address to completion status (true if completed)
    mapping(address => bool) public completed;

    /// @notice Mapping to track submission count per student
    /// @dev Maps student address to total number of submissions made
    mapping(address => uint256) public submissionCount;

    /**
     * @notice Emitted when a student makes a submission
     * @dev Event fired after each submission attempt, regardless of success
     * @param student Address of the student making the submission
     * @param submissionNumber The sequential submission number for this student
     * @param allTestsPassed Whether all test cases passed for this submission
     */
    event SubmissionMade(address indexed student, uint256 submissionNumber, bool allTestsPassed);

   /**
     * @notice Emitted when a student successfully completes the challenge
     * @dev Event fired only when all test cases pass for a submission
     * @param student Address of the student who completed the challenge
     * @param totalSubmissions Total number of submissions it took to complete
     */
    event ChallengeSolved(address indexed student, uint256 totalSubmissions);

    /**
     * @notice Constructor to initialize a new coding challenge
     * @dev Sets up the basic challenge information
     * @param _title The title of the coding challenge
     * @param _description Detailed description of the problem
     * @param _requirements Specific requirements and constraints
     */
    constructor(
        string memory _title,
        string memory _description,
        string memory _requirements
    ) {
        challengeTitle = _title;
        description = _description;
        requirements = _requirements;
    }

    function addTestCase(string memory expectedOutput) external {
        testCaseHashes.push(keccak256(abi.encodePacked(expectedOutput)));
    }
}
