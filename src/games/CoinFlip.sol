// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title Coin Flip Game
 * @author CantinaVerse-Tech
 * @notice A simple coin flip game where players can bet on heads or tails
 * @dev Uses a pseudo-random number generator, considering upgrading to Chainlink VRF in production
 */
contract CoinFlip is Ownable, ReentrancyGuard {
    // Game settings
    uint256 public houseEdge = 3; // 3% house edge
    uint256 public gameCounter;
    uint256 public houseBalance;

    // struct Game
    struct Game {
        address player;
        uint256 betAmount;
        bool isHeads;
        bool resolved;
        bool won;
        uint256 payout;
    }

    // Game data
    mapping(uint256 => Game) public games;

    // Events
    event CoinFlipped(address indexed player, bool heads, bool won, uint256 amount, uint256 payout);
    event HouseEdgeUpdated(uint256 newHouseEdge);
    event BetLimitsUpdated(uint256 newMinBet, uint256 newMaxBet);
    event HouseBalanceAdded(address indexed from, uint256 amount);
    event HouseBalanceWithdrawn(address indexed to, uint256 amount);

    constructor() {
        // Initialize with an empty house balance
    }

    /**
     * @notice Player flips a coin and bets on the outcome
     * @param isHeads True if player is betting on heads, false for tails
     */
    function flipCoin(bool isHeads) external payable nonReentrant {
        // Validate bet amount
        require(msg.value >= minBet, "Bet amount below minimum");
        require(msg.value <= maxBet, "Bet amount above maximum");

        // Ensure house has enough balance to pay potential win
        uint256 potentialPayout = (msg.value * (100 - houseEdge)) / 97; // Inverse of 3% house edge
        require(houseBalance >= potentialPayout - msg.value, "Insufficient house balance");

        // Generate pseudo-random result (note: not secure for production without additional randomness source)
        bool result = generateRandomBool();

        // Update statistics
        totalFlips++;
        totalEthWagered += msg.value;

        // Determine if player won
        bool playerWon = (result == isHeads);

        if (playerWon) {
            // Calculate payout
            uint256 payout = (msg.value * (100 - houseEdge)) / 100;

            // Update house balance
            houseBalance = houseBalance + msg.value - payout;

            // Send winnings to player
            (bool success,) = payable(msg.sender).call{ value: payout }("");
            require(success, "Transfer to winner failed");

            emit CoinFlipped(msg.sender, isHeads, true, msg.value, payout);
        } else {
            // Player lost, add bet to house balance
            houseBalance += msg.value;

            emit CoinFlipped(msg.sender, isHeads, false, msg.value, 0);
        }
    }

    /**
     * @notice Generate a pseudo-random boolean value
     * @dev Not secure for production use
     * @return A pseudo-random boolean
     */
    function generateRandomBool() internal view returns (bool) {
        uint256 randomValue =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, totalFlips)));

        return randomValue % 2 == 0;
    }

    /**
     * @notice Add funds to the house balance
     */
    function addHouseBalance() external payable onlyOwner {
        houseBalance += msg.value;
        emit HouseBalanceAdded(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw from the house balance
     * @param amount Amount to withdraw
     */
    function withdrawHouseBalance(uint256 amount) external onlyOwner nonReentrant {
        require(amount <= houseBalance, "Insufficient house balance");

        houseBalance -= amount;

        (bool success,) = payable(owner()).call{ value: amount }("");
        require(success, "Transfer failed");

        emit HouseBalanceWithdrawn(owner(), amount);
    }

    /**
     * @notice Update the house edge percentage
     * @param newHouseEdge New house edge percentage (1-20)
     */
    function setHouseEdge(uint256 newHouseEdge) external onlyOwner {
        require(newHouseEdge >= 1 && newHouseEdge <= 20, "House edge must be between 1% and 20%");
        houseEdge = newHouseEdge;
        emit HouseEdgeUpdated(newHouseEdge);
    }

    /**
     * @notice Update bet limits
     * @param newMinBet New minimum bet
     * @param newMaxBet New maximum bet
     */
    function setBetLimits(uint256 newMinBet, uint256 newMaxBet) external onlyOwner {
        require(newMinBet < newMaxBet, "Min bet must be less than max bet");
        minBet = newMinBet;
        maxBet = newMaxBet;
        emit BetLimitsUpdated(newMinBet, newMaxBet);
    }

    /**
     * @notice Fallback function to accept ETH
     */
    receive() external payable {
        houseBalance += msg.value;
        emit HouseBalanceAdded(msg.sender, msg.value);
    }
}
