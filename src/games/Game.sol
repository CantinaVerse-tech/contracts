// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TriviaChallenge
 * @author CantinaVerse-Tech
 * @dev A quiz-based game where players pay to enter, answer questions, and earn rewards.
 */
contract TriviaChallenge is Ownable, ReentrancyGuard {
    // Public variables
    uint256 public entryFee = 0 ether;
    uint256 public rewardPerCorrectAnswer = 0 ether;

    // Struct Question
    struct Question {
        string questionText;
        string[] options;
        uint8 correctOption; // Index of the correct option
    }

    // Struct Player
    struct Player {
        uint256 score;
        uint256 balance;
    }

    // Public Mappings
    Question[] public questions;
    mapping(address => Player) public players;

    // Events
    event QuestionAdded(uint256 questionId);
    event AnswerSubmitted(address indexed player, uint256 questionId, bool isCorrect);
    event RewardClaimed(address indexed player, uint256 amount);

    /**
     * @dev Adds a new question to the quiz.
     * @param _questionText The text of the question.
     * @param _options An array of answer options.
     * @param _correctOption The index of the correct option in the _options array.
     */
    function addQuestion(
        string memory _questionText,
        string[] memory _options,
        uint8 _correctOption
    )
        external
        onlyOwner
    {
        require(_correctOption < _options.length, "Invalid correct option index");
        questions.push(Question({ questionText: _questionText, options: _options, correctOption: _correctOption }));
        emit QuestionAdded(questions.length - 1);
    }

    /**
     * @dev Allows a player to answer a question by paying the entry fee.
     * @param _questionId The ID of the question to answer.
     * @param _selectedOption The index of the selected answer option.
     */
    function answerQuestion(uint256 _questionId, uint8 _selectedOption) external payable nonReentrant {
        require(msg.value == entryFee, "Incorrect entry fee");
        require(_questionId < questions.length, "Invalid question ID");
        require(_selectedOption < questions[_questionId].options.length, "Invalid option selected");

        bool isCorrect = (_selectedOption == questions[_questionId].correctOption);
        if (isCorrect) {
            players[msg.sender].score += 1;
            players[msg.sender].balance += rewardPerCorrectAnswer;
        }

        emit AnswerSubmitted(msg.sender, _questionId, isCorrect);
    }

    /**
     * @dev Allows a player to claim their accumulated rewards.
     */
    function claimReward() external nonReentrant {
        uint256 reward = players[msg.sender].balance;
        require(reward > 0, "No rewards to claim");
        players[msg.sender].balance = 0;
        (bool success,) = payable(msg.sender).call{ value: reward }("");
        require(success, "Transfer failed");
        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Allows the owner to withdraw the contract's balance.
     */
    function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No balance to withdraw");
        (bool success,) = payable(owner()).call{ value: contractBalance }("");
        require(success, "Transfer failed");
    }

    /**
     * @dev Returns the total number of questions.
     */
    function getTotalQuestions() external view returns (uint256) {
        return questions.length;
    }
}
