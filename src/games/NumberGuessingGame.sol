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
}
