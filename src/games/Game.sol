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
}
