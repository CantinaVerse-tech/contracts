// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

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
}
