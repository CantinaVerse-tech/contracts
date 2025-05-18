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

    // Contract state
    uint256 public currentChallengeId;
    uint256 public constant MAX_DURATION = 10 minutes;
    uint256 public constant MIN_DURATION = 30 seconds;
    uint256 public constant MIN_ENTRY_FEE = 0.001 ether;
    uint256 public protocolFeePercentage = 500; // 5% in basis points
    uint256 public protocolFeeBalance;

    // Anti-cheat parameters
    uint256 public maxClicksPerSecond = 20; // Max humanly possible clicks per second
    mapping(address => uint256) public lastClickTime;
    mapping(address => uint256) public clicksInCurrentSecond;

    // Storage
    mapping(uint256 => Challenge) public challenges;

    // Events
    event ChallengeCreated(uint256 indexed challengeId, uint256 duration, uint256 entryFee);
    event PlayerJoined(uint256 indexed challengeId, address indexed player);
    event ClickRecorded(uint256 indexed challengeId, address indexed player, uint256 totalClicks);
    event ChallengeEnded(uint256 indexed challengeId, address winner, uint256 prizeAmount);
    event PrizeDistributed(uint256 indexed challengeId, address winner, uint256 amount);
    event ProtocolFeeUpdated(uint256 newFeePercentage);
    event MaxClicksPerSecondUpdated(uint256 newMaxClicks);
}
