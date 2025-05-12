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
}
