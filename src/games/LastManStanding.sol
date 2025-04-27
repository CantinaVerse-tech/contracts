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

    /**
     * @notice Creates a new Last Man Standing game
     * @param _entryFee The entry fee for the game
     * @param _timeExtension The time extension for the game
     * @dev Return the ID of the created game
     */
    function createGame(uint256 _entryFee, uint256 _timeExtension) external returns (uint256) {
        require(_entryFee > 0, "Entry fee must be > 0");
        require(_timeExtension >= 30, "Time extension too short"); // Minimum 30 seconds for fairness

        uint256 gameId = nextGameId;
        nextGameId++;

        games[gameId] = Game({
            entryFee: _entryFee,
            timeExtension: _timeExtension,
            endTime: block.timestamp + _timeExtension,
            lastPlayer: address(0),
            active: true,
            pot: 0,
            creator: msg.sender
        });

        emit GameCreated(gameId, msg.sender, _entryFee, _timeExtension);

        return gameId;
    }

    /**
     * @notice Joins a specific game
     * @param _gameId The ID of the game to join
     * @dev Must pay the entry fee
     */
    function joinGame(uint256 _gameId) external payable {
        Game storage game = games[_gameId];
        require(game.active, "Game not active");
        require(block.timestamp <= game.endTime, "Game has already ended");
        require(msg.value == game.entryFee, "Incorrect entry fee");

        game.pot += msg.value;
        game.lastPlayer = msg.sender;
        game.endTime = block.timestamp + game.timeExtension;

        emit PlayerJoined(_gameId, msg.sender, game.endTime);
    }

    /**
     * @notice Claims the prize for a specific game
     * @param _gameId The ID of the game to claim the prize for
     * @dev Must be the last player who joined the game
     */
    function claimPrize(uint256 _gameId) external {
        Game storage game = games[_gameId];
        require(game.active, "Game not active");
        require(block.timestamp > game.endTime, "Game still ongoing");
        require(msg.sender == game.lastPlayer, "Only last player can claim");

        uint256 prizeAmount = game.pot;
        game.active = false;
        game.pot = 0;

        (bool success,) = msg.sender.call{ value: prizeAmount }("");
        require(success, "Transfer failed");

        emit PrizeClaimed(_gameId, msg.sender, prizeAmount);
    }

    /**
     * @notice Withdraws the prize for a specific game
     * @param _gameId The ID of the game to claim the prize for
     * @dev Must be the creator of the game
     */
    function creatorWithdraw(uint256 _gameId) external {
        Game storage game = games[_gameId];
        require(game.active, "Game not active");
        require(msg.sender == game.creator, "Only creator can withdraw");
        require(game.lastPlayer == address(0), "Players already joined");

        uint256 prizeAmount = game.pot;
        game.active = false;
        game.pot = 0;

        (bool success,) = msg.sender.call{ value: prizeAmount }("");
        require(success, "Withdrawal failed");
    }
}
