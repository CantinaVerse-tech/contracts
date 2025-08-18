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
}
