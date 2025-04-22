// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

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
    event GameCreated(uint256 indexed gameId, address indexed player, uint256 betAmount, bool isHeads);
    event GameResolved(uint256 indexed gameId, bool result, bool won, uint256 payout);
    event HouseBalanceAdded(address indexed from, uint256 amount);
    event HouseBalanceWithdrawn(address indexed to, uint256 amount);
    event HouseEdgeUpdated(uint256 newEdge);

    constructor() {
        // Initialize with an empty house balance
    }

    /**
     * @notice Create a new coin flip game
     * @param isHeads True if the player wants to bet on heads, false if they want to bet on tails
     * @dev Players can bet on heads or tails
     */
    function createGame(bool isHeads) external payable nonReentrant {
        require(msg.value >= 0, "Must bet >= 0");
        uint256 potentialPayout = (msg.value * (100 - houseEdge)) / 100;
        require(houseBalance >= potentialPayout - msg.value, "Insufficient house balance");

        uint256 gameId = ++gameCounter;
        games[gameId] =
            Game({ player: msg.sender, betAmount: msg.value, isHeads: isHeads, resolved: false, won: false, payout: 0 });

        emit GameCreated(gameId, msg.sender, msg.value, isHeads);
    }

    /**
     * @notice Resolve a specific game
     * @param gameId The ID of the game to resolve
     * @dev Only the player who created the game can resolve it
     */
    function resolveGame(uint256 gameId) external nonReentrant {
        Game storage game = games[gameId];
        require(game.player == msg.sender, "Not your game");
        require(!game.resolved, "Already resolved");

        bool result = generateRandomBool(gameId);
        bool playerWon = (result == game.isHeads);
        game.resolved = true;
        game.won = playerWon;

        if (playerWon) {
            uint256 payout = (game.betAmount * (100 - houseEdge)) / 100;
            game.payout = payout;
            houseBalance = houseBalance + game.betAmount - payout;

            (bool success,) = payable(msg.sender).call{ value: payout }("");
            require(success, "Transfer failed");
        } else {
            houseBalance += game.betAmount;
        }

        emit GameResolved(gameId, result, playerWon, game.payout);
    }

    /**
     * @notice Generate a pseudo-random boolean value
     * @param gameId The ID of the game
     * @dev Not secure for production use
     * @return A pseudo-random boolean
     */
    function generateRandomBool(uint256 gameId) internal view returns (bool) {
        uint256 randomValue =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, gameId)));
        return randomValue % 2 == 0;
    }

    /**
     * @notice Add funds to the house balance
     * @dev Only the owner can add funds
     */
    function addHouseBalance() external payable onlyOwner {
        houseBalance += msg.value;
        emit HouseBalanceAdded(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw from the house balance
     * @param amount Amount to withdraw
     * @dev Only the owner can withdraw
     */
    function withdrawHouseBalance(uint256 amount) external onlyOwner nonReentrant {
        require(amount <= houseBalance, "Not enough balance");
        houseBalance -= amount;
        (bool success,) = payable(owner()).call{ value: amount }("");
        require(success, "Withdraw failed");
        emit HouseBalanceWithdrawn(owner(), amount);
    }

    /**
     * @notice Update the house edge percentage
     * @param newEdge New edge percentage (1-20%)
     * @dev Only the owner can update the edge
     */
    function setHouseEdge(uint256 newEdge) external onlyOwner {
        require(newEdge >= 1 && newEdge <= 20, "Edge must be 1-20%");
        houseEdge = newEdge;
        emit HouseEdgeUpdated(newEdge);
    }

    /**
     * @notice Fallback function to accept ETH
     */
    receive() external payable {
        houseBalance += msg.value;
        emit HouseBalanceAdded(msg.sender, msg.value);
    }
}
