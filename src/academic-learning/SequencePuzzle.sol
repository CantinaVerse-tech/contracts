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

    string public pattern;

}
