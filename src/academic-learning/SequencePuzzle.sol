// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SequencePuzzle
 * @author CantinaVerse-Tech
 * @notice A mathematical sequence puzzle game where students must identify the next value in a sequence
 * @dev This contract implements a puzzle system where users attempt to guess the next number in a mathematical sequence.
 *      Each user can make multiple attempts, and their progress is tracked individually.
 * @custom:educational This contract is designed for educational purposes to teach pattern recognition and mathematical sequences
 */
contract SequencePuzzle {
    /// @notice Human-readable description of the puzzle challenge
    /// @dev This string provides context and instructions for the puzzle
    string public puzzleDescription;

    /// @notice The mathematical sequence array that students must analyze
    /// @dev Contains the known values in the sequence that lead to the solution
    uint256[] public sequence;

    /// @notice The correct answer - the next value in the sequence
    /// @dev Immutable to prevent modification after deployment, ensuring puzzle integrity
    uint256 public immutable nextValue;

    /// @notice Description of the mathematical pattern or rule governing the sequence
    /// @dev Only revealed to students who successfully solve the puzzle
    string public pattern;

    /// @notice Tracks the number of attempts made by each student
    /// @dev Maps student address to their total number of guesses
    mapping(address => uint256) public attempts;

    /// @notice Tracks whether each student has successfully solved the puzzle
    /// @dev Maps student address to boolean indicating completion status
    mapping(address => bool) public solved;

    /**
     * @notice Emitted when a student submits a guess
     * @param student The address of the student making the attempt
     * @param guess The value guessed by the student
     * @param correct Whether the guess was correct or not
     * @param attemptCount The total number of attempts made by this student
     */
    event Attempt(address indexed student, uint256 guess, bool correct, uint256 attemptCount);

}
