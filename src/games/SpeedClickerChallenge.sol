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
    // Custom errors
    error InvalidDuration();
    error InvalidEntryFee();
    error ChallengeNotActive();
    error AlreadyJoined();
    error NotJoined();
    error ChallengeNotFinished();
    error PrizeAlreadyDistributed();
    error InsufficientFunds();
    error TooManyClicks();
    error InvalidFeePercentage();

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

    constructor() { }

    /**
     * @dev Creates a new clicking challenge
     * @param _duration Duration of the challenge in seconds
     * @param _entryFee Entry fee required to join (in wei)
     */
    function createChallenge(uint256 _duration, uint256 _entryFee) external whenNotPaused {
        if (_duration < MIN_DURATION || _duration > MAX_DURATION) {
            revert InvalidDuration();
        }
        if (_entryFee < MIN_ENTRY_FEE) {
            revert InvalidEntryFee();
        }

        currentChallengeId++;
        Challenge storage newChallenge = challenges[currentChallengeId];

        newChallenge.challengeId = currentChallengeId;
        newChallenge.duration = _duration;
        newChallenge.entryFee = _entryFee;
        newChallenge.state = GameState.WAITING;
        newChallenge.prizeDistributed = false;

        emit ChallengeCreated(currentChallengeId, _duration, _entryFee);
    }

    /**
     * @dev Join an active challenge by paying the entry fee
     * @param _challengeId The ID of the challenge to join
     */
    function joinChallenge(uint256 _challengeId) external payable nonReentrant whenNotPaused {
        Challenge storage challenge = challenges[_challengeId];

        if (challenge.state != GameState.WAITING) {
            revert ChallengeNotActive();
        }
        if (challenge.hasJoined[msg.sender]) {
            revert AlreadyJoined();
        }
        if (msg.value != challenge.entryFee) {
            revert InsufficientFunds();
        }

        challenge.hasJoined[msg.sender] = true;
        challenge.participants.push(msg.sender);
        challenge.totalPrizePool += msg.value;

        emit PlayerJoined(_challengeId, msg.sender);
    }

    /**
     * @dev Start a challenge (can only be called by owner)
     * @param _challengeId The ID of the challenge to start
     */
    function startChallenge(uint256 _challengeId) external onlyOwner {
        Challenge storage challenge = challenges[_challengeId];

        if (challenge.state != GameState.WAITING) {
            revert ChallengeNotActive();
        }

        challenge.startTime = block.timestamp;
        challenge.endTime = block.timestamp + challenge.duration;
        challenge.state = GameState.ACTIVE;
    }

    /**
     * @dev Record a click for the calling player
     * @param _challengeId The ID of the active challenge
     */
    function click(uint256 _challengeId) external whenNotPaused {
        Challenge storage challenge = challenges[_challengeId];

        if (challenge.state != GameState.ACTIVE) {
            revert ChallengeNotActive();
        }
        if (!challenge.hasJoined[msg.sender]) {
            revert NotJoined();
        }
        if (block.timestamp >= challenge.endTime) {
            // Auto-end the challenge
            _endChallenge(_challengeId);
            revert ChallengeNotActive();
        }

        // Anti-cheat: Check clicking rate
        _enforceClickingLimits(msg.sender);

        challenge.playerClicks[msg.sender]++;

        // Update max clicks and potential winner
        if (challenge.playerClicks[msg.sender] > challenge.maxClicks) {
            challenge.maxClicks = challenge.playerClicks[msg.sender];
            challenge.winner = msg.sender;
        }

        emit ClickRecorded(_challengeId, msg.sender, challenge.playerClicks[msg.sender]);
    }

    /**
     * @dev End a challenge and determine the winner
     * @param _challengeId The ID of the challenge to end
     */
    function endChallenge(uint256 _challengeId) external {
        Challenge storage challenge = challenges[_challengeId];

        if (challenge.state != GameState.ACTIVE) {
            revert ChallengeNotActive();
        }
        if (block.timestamp < challenge.endTime && msg.sender != owner()) {
            revert ChallengeNotActive();
        }

        _endChallenge(_challengeId);
    }

    /**
     * @dev Internal function to end a challenge
     * @param _challengeId The ID of the challenge to end
     */
    function _endChallenge(uint256 _challengeId) internal {
        Challenge storage challenge = challenges[_challengeId];
        challenge.state = GameState.FINISHED;

        emit ChallengeEnded(_challengeId, challenge.winner, challenge.totalPrizePool);
    }

    /**
     * @dev Distribute prize to the winner
     * @param _challengeId The ID of the finished challenge
     */
    function distributePrize(uint256 _challengeId) external nonReentrant {
        Challenge storage challenge = challenges[_challengeId];

        if (challenge.state != GameState.FINISHED) {
            revert ChallengeNotFinished();
        }
        if (challenge.prizeDistributed) {
            revert PrizeAlreadyDistributed();
        }

        challenge.prizeDistributed = true;

        if (challenge.winner == address(0)) {
            // No winner, refund all participants
            uint256 refundAmount = challenge.entryFee;
            for (uint256 i = 0; i < challenge.participants.length; i++) {
                address participant = challenge.participants[i];
                (bool success,) = participant.call{ value: refundAmount }("");
                require(success, "Refund failed");
            }
        } else {
            // Calculate and distribute prize
            uint256 protocolFee = (challenge.totalPrizePool * protocolFeePercentage) / 10_000;
            uint256 winnerPrize = challenge.totalPrizePool - protocolFee;

            protocolFeeBalance += protocolFee;

            (bool success,) = challenge.winner.call{ value: winnerPrize }("");
            require(success, "Prize transfer failed");

            emit PrizeDistributed(_challengeId, challenge.winner, winnerPrize);
        }
    }

    /**
     * @dev Enforce anti-cheat clicking limits
     * @param _player The player to check
     */
    function _enforceClickingLimits(address _player) internal {
        uint256 currentTime = block.timestamp;

        if (lastClickTime[_player] == currentTime) {
            clicksInCurrentSecond[_player]++;
            if (clicksInCurrentSecond[_player] > maxClicksPerSecond) {
                revert TooManyClicks();
            }
        } else {
            clicksInCurrentSecond[_player] = 1;
            lastClickTime[_player] = currentTime;
        }
    }

    // View functions

    /**
     * @dev Get player's click count for a challenge
     * @param _challengeId The challenge ID
     * @param _player The player address
     * @return The number of clicks
     */
    function getPlayerClicks(uint256 _challengeId, address _player) external view returns (uint256) {
        return challenges[_challengeId].playerClicks[_player];
    }

    /**
     * @dev Check if a player has joined a challenge
     * @param _challengeId The challenge ID
     * @param _player The player address
     * @return True if the player has joined
     */
    function hasPlayerJoined(uint256 _challengeId, address _player) external view returns (bool) {
        return challenges[_challengeId].hasJoined[_player];
    }

    /**
     * @dev Get all participants in a challenge
     * @param _challengeId The challenge ID
     * @return Array of participant addresses
     */
    function getChallengeParticipants(uint256 _challengeId) external view returns (address[] memory) {
        return challenges[_challengeId].participants;
    }

    /**
     * @dev Get basic challenge info
     * @param _challengeId The challenge ID
     * @dev Return Basic challenge information
     */
    function getChallengeInfo(uint256 _challengeId)
        external
        view
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256 entryFee,
            uint256 totalPrizePool,
            uint256 maxClicks,
            address winner,
            GameState state,
            bool prizeDistributed
        )
    {
        Challenge storage challenge = challenges[_challengeId];
        return (
            challenge.startTime,
            challenge.endTime,
            challenge.entryFee,
            challenge.totalPrizePool,
            challenge.maxClicks,
            challenge.winner,
            challenge.state,
            challenge.prizeDistributed
        );
    }

    // Admin functions

    /**
     * @dev Update protocol fee percentage
     * @param _newFeePercentage New fee percentage in basis points
     */
    function updateProtocolFee(uint256 _newFeePercentage) external onlyOwner {
        if (_newFeePercentage > 2000) {
            // Max 20%
            revert InvalidFeePercentage();
        }
        protocolFeePercentage = _newFeePercentage;
        emit ProtocolFeeUpdated(_newFeePercentage);
    }

    /**
     * @dev Update max clicks per second for anti-cheat
     * @param _newMaxClicks New maximum clicks per second
     */
    function updateMaxClicksPerSecond(uint256 _newMaxClicks) external onlyOwner {
        maxClicksPerSecond = _newMaxClicks;
        emit MaxClicksPerSecondUpdated(_newMaxClicks);
    }

    /**
     * @dev Withdraw accumulated protocol fees
     */
    function withdrawProtocolFees() external onlyOwner nonReentrant {
        uint256 amount = protocolFeeBalance;
        protocolFeeBalance = 0;

        (bool success,) = owner().call{ value: amount }("");
        require(success, "Withdrawal failed");
    }

    /**
     * @dev Emergency pause function
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause function
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @dev Emergency withdrawal function (only if paused)
     */
    function emergencyWithdraw() external onlyOwner whenPaused nonReentrant {
        uint256 balance = address(this).balance;
        (bool success,) = owner().call{ value: balance }("");
        require(success, "Emergency withdrawal failed");
    }
}
