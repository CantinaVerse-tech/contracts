// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title SpeedClickerChallenge
 * @author CantinaVerse-Tech
 * @dev A blockchain game where players compete to click the most in a time window
 * @notice Players pay an entry fee and compete in clicking challenges
 */
contract SpeedClickerChallenge is Ownable, ReentrancyGuard, Pausable { }
