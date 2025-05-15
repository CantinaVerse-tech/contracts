// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TicTacToe
 * @author CantinaVerse-Tech
 * @notice A multi-game Tic-Tac-Toe smart contract supporting concurrent matches.
 */
contract TicTacToe is ReentrancyGuard {
    enum Player {
        None,
        X,
        O
    }
    enum GameState {
        WaitingForPlayer,
        InProgress,
        Finished
    }

    struct Game {
        address playerX;
        address playerO;
        Player[3][3] board;
        Player currentPlayer;
        GameState gameState;
        address winner;
    }

    uint256 public gameCounter;
    mapping(uint256 => Game) public games;

    event GameCreated(uint256 indexed gameId, address indexed creator);
    event GameJoined(uint256 indexed gameId, address indexed joiner);
    event MoveMade(uint256 indexed gameId, address indexed player, uint8 row, uint8 col);
    event GameWon(uint256 indexed gameId, address indexed winner);
    event GameDraw(uint256 indexed gameId);

    constructor() { }

    /**
     * @notice Creates a new game and assigns the sender as player X.
     * @return gameId The unique identifier for the created game.
     */
    function createGame() external returns (uint256 gameId) {
        gameId = gameCounter++;
        Game storage game = games[gameId];
        game.playerX = msg.sender;
        game.currentPlayer = Player.X;
        game.gameState = GameState.WaitingForPlayer;

        emit GameCreated(gameId, msg.sender);
    }

    /**
     * @notice Allows a second player to join an existing game.
     * @param gameId The identifier of the game to join.
     */
    function joinGame(uint256 gameId) external {
        Game storage game = games[gameId];
        require(game.gameState == GameState.WaitingForPlayer, "Game not available for joining");
        require(game.playerX != msg.sender, "Cannot join your own game");

        game.playerO = msg.sender;
        game.gameState = GameState.InProgress;

        emit GameJoined(gameId, msg.sender);
    }

    /**
     * @notice Checks if the specified player has won.
     * @param player The player to check.
     * @return True if the player has won, false otherwise.
     */
    function checkWin(Player player) internal view returns (bool) {
        for (uint8 i = 0; i < 3; i++) {
            if (
                (board[i][0] == player && board[i][1] == player && board[i][2] == player)
                    || (board[0][i] == player && board[1][i] == player && board[2][i] == player)
            ) {
                return true;
            }
        }
        if (
            (board[0][0] == player && board[1][1] == player && board[2][2] == player)
                || (board[0][2] == player && board[1][1] == player && board[2][0] == player)
        ) {
            return true;
        }
        return false;
    }

    /**
     * @notice Checks if the board is full.
     * @return True if the board is full, false otherwise.
     */
    function isBoardFull() internal view returns (bool) {
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = 0; j < 3; j++) {
                if (board[i][j] == Player.None) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * @notice Resets the game to its initial state.
     */
    function resetGame() external onlyOwner {
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = 0; j < 3; j++) {
                board[i][j] = Player.None;
            }
        }
        playerX = address(0);
        playerO = address(0);
        currentPlayer = Player.None;
        gameState = GameState.WaitingForPlayer;
        winner = address(0);
    }
}
