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
contract SpeedClickerChallenge is Ownable, ReentrancyGuard, Pausable {
    // Game state
    enum GameState {
        WAITING,
        ACTIVE,
        FINISHED
    }

    // Challenge structure
    struct Challenge {
        uint256 challengeId;
        uint256 startTime;
        uint256 endTime;
        uint256 duration;
        uint256 entryFee;
        uint256 totalPrizePool;
        uint256 maxClicks;
        address winner;
        bool prizeDistributed;
        GameState state;
        mapping(address => uint256) playerClicks;
        mapping(address => bool) hasJoined;
        address[] participants;
    }
}
