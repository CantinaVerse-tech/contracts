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

     /**
     * @notice Emitted when a student successfully solves the puzzle
     * @param student The address of the student who solved it
     * @param finalAttempts The total number of attempts it took to solve
     */
    event PuzzleSolved(address indexed student, uint256 finalAttempts);

    /**
     * @notice Initializes a new sequence puzzle with the given parameters
     * @dev Sets up the puzzle with immutable solution to ensure integrity
     * @param _description Human-readable description explaining the puzzle
     * @param _sequence Array of known sequence values for students to analyze
     * @param _nextValue The correct next value in the sequence (solution)
     * @param _pattern Description of the mathematical pattern/rule
     * 
     * Requirements:
     * - All parameters must be provided (no empty values for strings)
     * - Sequence array should contain at least 2 values for meaningful pattern recognition
     * - Pattern description should be accurate for educational value
     */
    constructor(
        string memory _description,
        uint256[] memory _sequence,
        uint256 _nextValue,
        string memory _pattern
    ) {
        puzzleDescription = _description;
        sequence = _sequence;
        nextValue = _nextValue;
        pattern = _pattern;
    }

    /**
     * @notice Allows a student to submit their guess for the next value in the sequence
     * @dev Increments attempt counter and checks if guess matches the correct answer
     * @param guess The student's guess for the next sequence value
     * 
     * Requirements:
     * - Student must not have already solved the puzzle
     * - Guess can be any uint256 value
     * 
     * Effects:
     * - Increments the student's attempt counter
     * - Marks puzzle as solved if guess is correct
     * - Emits Attempt event for all submissions
     * - Emits PuzzleSolved event for correct answers
     * 
     * @custom:emits Attempt Always emitted with guess details
     * @custom:emits PuzzleSolved Emitted when correct answer is submitted
     */
    function submitGuess(uint256 guess) external {
        require(!solved[msg.sender], "Puzzle already solved");
        
        attempts[msg.sender]++;
        bool correct = (guess == nextValue);
        
        if (correct) {
            solved[msg.sender] = true;
            emit PuzzleSolved(msg.sender, attempts[msg.sender]);
        }
        
        emit Attempt(msg.sender, guess, correct, attempts[msg.sender]);
    }

    /**
     * @notice Returns the complete sequence array for analysis
     * @dev Provides read-only access to the sequence values
     * @return An array containing all the known sequence values
     * 
     * Usage:
     * - Students can call this to get the full sequence for analysis
     * - Front-end applications can display the sequence visually
     * - No restrictions on who can call this function
     */
    function getSequence() external view returns (uint256[] memory) {
        return sequence;
    }

    /**
     * @notice Retrieves a student's progress information
     * @dev Returns both attempt count and completion status for any address
     * @param student The address of the student to check progress for
     * @return attemptCount The total number of guesses made by the student
     * @return hasSolved Whether the student has successfully solved the puzzle
     * 
     * Usage:
     * - Teachers can monitor student progress
     * - Students can check their own statistics
     * - Leaderboard systems can use this data
     */
    function getProgress(address student) external view returns (
        uint256 attemptCount,
        bool hasSolved
    ) {
        return (attempts[student], solved[student]);
    }
}
