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
contract NumberGuessingGame is Ownable, ReentrancyGuard { }
