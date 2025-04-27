// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @title LastManStanding
/// @author CantinaVerse-Tech
/// @notice Anyone can create a Last Man Standing game. Last player before time runs out wins the pot.
contract LastManStanding {
    // @notice Game struct to hold individual game data
    struct Game {
        uint256 entryFee;
        uint256 timeExtension; // in seconds
        uint256 endTime;
        address lastPlayer;
        bool active;
        uint256 pot;
        address creator;
    }

    // @notice Total number of games created
    uint256 public nextGameId;

    // @notice Map of gameId to Game data
    mapping(uint256 => Game) public games;

    // @notice Event emitted when a game is created
    event GameCreated(uint256 indexed gameId, address indexed creator, uint256 entryFee, uint256 timeExtension);

    // @notice Event emitted when a player joins a game
    event PlayerJoined(uint256 indexed gameId, address indexed player, uint256 newEndTime);

    // @notice Event emitted when a game ends
    event PrizeClaimed(uint256 indexed gameId, address indexed winner, uint256 prizeAmount);
}
