// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TicTacToe
 * @author CantinaVerse-Tech
 * @dev A two-player Tic-Tac-Toe game implemented as a smart contract.
 */
contract TicTacToe is ReentrancyGuard, Ownable {
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

    Player[3][3] public board;
    address public playerX;
    address public playerO;
    Player public currentPlayer;
    GameState public gameState;
    address public winner;

    event GameStarted(address playerX, address playerO);
    event MoveMade(address player, uint8 row, uint8 col);
    event GameWon(address winner);
    event GameDraw();

    modifier onlyPlayers() {
        require(msg.sender == playerX || msg.sender == playerO, "Not a player");
        _;
    }

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
}
