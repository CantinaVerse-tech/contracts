// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title MultipleChoiceQuiz
 * @author CantinaVerse-Tech
 * @notice A smart contract for creating and managing multiple-choice quizzes with scoring and pass/fail functionality
 * @dev This contract allows quiz creation, student submissions, and result tracking with immutable quiz data
 * @custom:version 1.0.0
 */
contract MultipleChoiceQuiz {
    /*//////////////////////////////////////////////////////////////
                               STRUCTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Represents a single multiple-choice question
     * @dev All question data is stored on-chain and immutable after creation
     * @param question The question text to be displayed to students
     * @param options Array of possible answer choices for the question
     * @param correctAnswer Zero-based index of the correct option in the options array
     * @param explanation Detailed explanation provided after quiz submission
     */
    struct Question {
        string question;
        string[] options;
        uint8 correctAnswer; // Index of correct option (0-based)
        string explanation;
    }

    /*//////////////////////////////////////////////////////////////
                           STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The title/name of this quiz instance
    /// @dev Set once during contract deployment and cannot be changed
    string public quizTitle;

    /// @notice Array storing all questions for this quiz
    /// @dev Questions can only be added, never modified or removed
    Question[] public questions;

    /// @notice Minimum percentage score required to pass the quiz (0-100)
    /// @dev Set during deployment and used to determine pass/fail status
    uint256 public passingScore;

    /*//////////////////////////////////////////////////////////////
                              MAPPINGS
    //////////////////////////////////////////////////////////////*/

    /// @notice Maps student address to their answer for each question
    /// @dev Structure: studentAnswers[studentAddress][questionIndex] = selectedAnswerIndex
    mapping(address => mapping(uint256 => uint8)) public studentAnswers;

    /// @notice Tracks whether a student has already submitted their quiz
    /// @dev Prevents multiple submissions from the same address
    mapping(address => bool) public hasSubmitted;

    /// @notice Maps student address to their calculated score (0-100)
    /// @dev Score is calculated as (correctAnswers / totalQuestions) * 100
    mapping(address => uint256) public scores;

    /// @notice Maps student address to their pass/fail status
    /// @dev True if student's score >= passingScore, false otherwise
    mapping(address => bool) public passed;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Emitted when a student successfully submits their quiz
     * @param student The address of the student who submitted the quiz
     * @param score The calculated score as a percentage (0-100)
     * @param passed Whether the student achieved a passing score
     */
    event QuizSubmitted(address indexed student, uint256 score, bool passed);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Initializes a new quiz with a title and passing score requirement
     * @dev The quiz starts empty - questions must be added separately using addQuestion()
     * @param _title The display title for this quiz
     * @param _passingScore Minimum percentage (0-100) required to pass the quiz
     */
    constructor(
        string memory _title,
        uint256 _passingScore
    ) {
        quizTitle = _title;
        passingScore = _passingScore;
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Adds a new question to the quiz
     * @dev Questions are immutable once added. The correct answer index must be valid.
     * @param _question The question text to display
     * @param _options Array of possible answer choices
     * @param _correctAnswer Zero-based index of the correct option (must be < options.length)
     * @param _explanation Explanation text shown after submission
     * 
     * Requirements:
     * - _correctAnswer must be a valid index within _options array
     * - Can be called multiple times to build the complete quiz
     * 
     * @custom:security No access control - anyone can add questions. Consider adding onlyOwner modifier for production use.
     */
    function addQuestion(
        string memory _question,
        string[] memory _options,
        uint8 _correctAnswer,
        string memory _explanation
    ) external {
        // Validate that the correct answer index exists within the options array
        require(_correctAnswer < _options.length, "Invalid correct answer index");
        
        // Add the new question to storage
        questions.push(Question({
            question: _question,
            options: _options,
            correctAnswer: _correctAnswer,
            explanation: _explanation
        }));
    }

function submitQuiz(uint8[] calldata answers) external {
        require(!hasSubmitted[msg.sender], "Quiz already submitted");
        require(answers.length == questions.length, "Answer count mismatch");
        
        uint256 correct = 0;
        
        for (uint256 i = 0; i < questions.length; i++) {
            studentAnswers[msg.sender][i] = answers[i];
            if (answers[i] == questions[i].correctAnswer) {
                correct++;
            }
        }
        
        hasSubmitted[msg.sender] = true;
        scores[msg.sender] = (correct * 100) / questions.length;
        passed[msg.sender] = scores[msg.sender] >= passingScore;
        
        emit QuizSubmitted(msg.sender, scores[msg.sender], passed[msg.sender]);
    }

    function getQuestion(uint256 index) external view returns (
        string memory question,
        string[] memory options
    ) {
        require(index < questions.length, "Question does not exist");
        return (questions[index].question, questions[index].options);
    }
    
    function getQuestionCount() external view returns (uint256) {
        return questions.length;
    }
    
    function getResults(address student) external view returns (
        uint256 score,
        bool hasPassed,
        bool submitted
    ) {
        return (scores[student], passed[student], hasSubmitted[student]);
    }
}
