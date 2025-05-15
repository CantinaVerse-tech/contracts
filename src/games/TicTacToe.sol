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

    event GameStarted(address playerX, address playerO);
    event MoveMade(address player, uint8 row, uint8 col);
    event GameWon(address winner);
    event GameDraw();

    /**
     * @notice Requires the message sender to be a player.
     * @dev This modifier is used to ensure that only players can interact with the contract.
     */
    modifier onlyPlayers() {
        require(msg.sender == playerX || msg.sender == playerO, "Not a player");
        _;
    }

    /**
     * @notice Requires the game to be in the specified state.
     * @param _state The game state to require
     */
    modifier inGameState(GameState _state) {
        require(gameState == _state, "Invalid game state");
        _;
    }

    /**
     * @notice Initializes the contract in a waiting state.
     */
    constructor() {
        gameState = GameState.WaitingForPlayer;
    }

    /**
     * @notice Allows players to join the game.
     */
    function joinGame() external inGameState(GameState.WaitingForPlayer) {
        require(playerX == address(0) || playerO == address(0), "Game is full");
        if (playerX == address(0)) {
            playerX = msg.sender;
        } else {
            require(msg.sender != playerX, "Player already joined");
            playerO = msg.sender;
            currentPlayer = Player.X;
            gameState = GameState.InProgress;
            emit GameStarted(playerX, playerO);
        }
    }

    /**
     * @notice Allows a player to make a move.
     * @param row The row index (0-2).
     * @param col The column index (0-2).
     */
    function makeMove(uint8 row, uint8 col) external onlyPlayers inGameState(GameState.InProgress) {
        require(row < 3 && col < 3, "Invalid move");
        require(board[row][col] == Player.None, "Cell occupied");
        require(
            (currentPlayer == Player.X && msg.sender == playerX) || (currentPlayer == Player.O && msg.sender == playerO),
            "Not your turn"
        );

        board[row][col] = currentPlayer;
        emit MoveMade(msg.sender, row, col);

        if (checkWin(currentPlayer)) {
            gameState = GameState.Finished;
            winner = msg.sender;
            emit GameWon(winner);
        } else if (isBoardFull()) {
            gameState = GameState.Finished;
            emit GameDraw();
        } else {
            currentPlayer = currentPlayer == Player.X ? Player.O : Player.X;
        }
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
