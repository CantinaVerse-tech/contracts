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
    struct Question {
        string question;
        string[] options;
        uint8 correctAnswer; // Index of correct option (0-based)
        string explanation;
    }

  string public quizTitle;
  Question[] public questions;
  uint256 public passingScore; // Percentage needed to pass (0-100)

  mapping(address => mapping(uint256 => uint8)) public studentAnswers;
  mapping(address => bool) public hasSubmitted;
  mapping(address => uint256) public scores;
  mapping(address => bool) public passed;

  event QuizSubmitted(address indexed student, uint256 score, bool passed);

  constructor(
        string memory _title,
        uint256 _passingScore
    ) {
        quizTitle = _title;
        passingScore = _passingScore;
    }

function addQuestion(
        string memory _question,
        string[] memory _options,
        uint8 _correctAnswer,
        string memory _explanation
    ) external {
        require(_correctAnswer < _options.length, "Invalid correct answer index");
        
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
