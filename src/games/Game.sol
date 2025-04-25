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
}
