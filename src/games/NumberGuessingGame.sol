// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title NumberGuessingGame
 * @author CantinaVerse-Tech
 * @dev A simple number guessing game where players pay a fee to guess a number.
 *      If a player guesses correctly, they win the accumulated jackpot.
 */
contract NumberGuessingGame is Ownable, ReentrancyGuard {
    /// @notice The secret number to be guessed (0-255)
    uint8 private secretNumber;

    /// @notice The fee required to make a guess (in wei)
    uint256 public guessFee;

    /// @notice The current jackpot amount (in wei)
    uint256 public jackpot;

    /// @notice Indicates whether the game is currently active
    bool public isActive;

    /// @notice Maximum number of attempts allowed before game ends
    uint256 public maxAttempts;

    /// @notice Current number of attempts made
    uint256 public attemptCount;

    /// @notice Address of the winner
    address public winner;

    /// @notice Event emitted when a player makes a guess
    event GuessMade(address indexed player, uint8 guess, bool isCorrect);

    /// @notice Event emitted when the game starts
    event GameStarted(uint8 secretNumber, uint256 guessFee, uint256 maxAttempts);

    /// @notice Event emitted when the game ends
    event GameEnded(address winner, uint256 jackpotAmount);

    /**
     * @notice Initializes the contract with a secret number, guess fee, and maximum attempts.
     * @param _secretNumber The number players need to guess (0-255).
     * @param _guessFee The fee required to make a guess (in wei).
     * @param _maxAttempts The maximum number of attempts allowed.
     */
    constructor(uint8 _secretNumber, uint256 _guessFee, uint256 _maxAttempts) payable {
        require(_guessFee > 0, "Guess fee must be greater than zero");
        require(_maxAttempts > 0, "Maximum attempts must be greater than zero");
        secretNumber = _secretNumber;
        guessFee = _guessFee;
        maxAttempts = _maxAttempts;
        isActive = true;
        jackpot = msg.value;
        emit GameStarted(secretNumber, guessFee, maxAttempts);
    }

    /**
     * @notice Allows a player to make a guess by paying the guess fee.
     * @param _guess The player's guessed number.
     */
    function makeGuess(uint8 _guess) external payable nonReentrant {
        require(isActive, "Game is not active");
        require(msg.value == guessFee, "Incorrect guess fee");
        require(msg.sender != owner(), "Owner cannot participate");

        jackpot += msg.value;
        attemptCount += 1;

        if (_guess == secretNumber) {
            isActive = false;
            winner = msg.sender;
            uint256 winnings = jackpot;
            jackpot = 0;
            payable(msg.sender).transfer(winnings);
            emit GuessMade(msg.sender, _guess, true);
            emit GameEnded(msg.sender, winnings);
        } else {
            emit GuessMade(msg.sender, _guess, false);
            if (attemptCount >= maxAttempts) {
                isActive = false;
                emit GameEnded(address(0), jackpot);
            }
        }
    }
}
