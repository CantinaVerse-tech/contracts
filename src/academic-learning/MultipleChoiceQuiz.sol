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

     /**
     * @notice Submits a student's answers and calculates their score
     * @dev Processes all answers, calculates score, determines pass/fail status, and emits event
     * @param answers Array of selected answer indices corresponding to each question
     * 
     * Requirements:
     * - Student must not have already submitted (prevents re-submission)
     * - answers array length must match the number of questions
     * - Each answer index should be valid for its corresponding question
     * 
     * Effects:
     * - Records all student answers in studentAnswers mapping
     * - Calculates and stores percentage score (0-100)
     * - Determines and stores pass/fail status
     * - Marks student as having submitted
     * - Emits QuizSubmitted event
     */
    function submitQuiz(uint8[] calldata answers) external {
        // Prevent multiple submissions from the same student
        require(!hasSubmitted[msg.sender], "Quiz already submitted");
        
        // Ensure student provided an answer for every question
        require(answers.length == questions.length, "Answer count mismatch");
        
        uint256 correct = 0;
        
        // Process each answer and count correct responses
        for (uint256 i = 0; i < questions.length; i++) {
            // Store the student's answer for this question
            studentAnswers[msg.sender][i] = answers[i];
            
            // Check if the answer is correct and increment counter
            if (answers[i] == questions[i].correctAnswer) {
                correct++;
            }
        }
        // Mark as submitted to prevent re-submission
        hasSubmitted[msg.sender] = true;
        
        // Calculate percentage score (0-100)
        scores[msg.sender] = (correct * 100) / questions.length;
        
        // Determine pass/fail status based on passing score threshold
        passed[msg.sender] = scores[msg.sender] >= passingScore;
        
        // Emit event with results
        emit QuizSubmitted(msg.sender, scores[msg.sender], passed[msg.sender]);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Retrieves a specific question and its answer options
     * @dev Returns question text and options array, but not the correct answer or explanation
     * @param index Zero-based index of the question to retrieve
     * @return question The question text
     * @return options Array of possible answer choices
     * 
     * Requirements:
     * - index must be less than the total number of questions
     * 
     * @custom:note This function intentionally does not return correctAnswer or explanation
     * to prevent students from cheating before submission
     */
    function getQuestion(uint256 index) external view returns (
        string memory question,
        string[] memory options
    ) {
        // Ensure the requested question exists
        require(index < questions.length, "Question does not exist");
        
        return (questions[index].question, questions[index].options);
    }
    
    /**
     * @notice Returns the total number of questions in this quiz
     * @dev Useful for frontend applications to iterate through all questions
     * @return The total count of questions added to this quiz
     */
    function getQuestionCount() external view returns (uint256) {
        return questions.length;
    }
    
    /**
     * @notice Retrieves a student's quiz results and submission status
     * @dev Can be called for any address, including addresses that haven't taken the quiz
     * @param student The address of the student to check
     * @return score The student's percentage score (0-100), or 0 if not submitted
     * @return hasPassed Whether the student achieved a passing score, false if not submitted
     * @return submitted Whether the student has submitted their quiz
     * 
     * @custom:note For students who haven't submitted, score will be 0 and hasPassed will be false
     */
    function getResults(address student) external view returns (
        uint256 score,
        bool hasPassed,
        bool submitted
    ) {
        return (scores[student], passed[student], hasSubmitted[student]);
    }
}
