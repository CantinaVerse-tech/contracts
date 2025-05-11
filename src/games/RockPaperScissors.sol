// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title RockPaperScissors
 * @author CantinaVerse-Tech
 * @dev A two-player Rock-Paper-Scissors game using a commit-reveal scheme.
 */
contract RockPaperScissors is ReentrancyGuard {
    using ECDSA for bytes32;

    enum Move {
        None,
        Rock,
        Paper,
        Scissors
    }
    enum GameState {
        NotStarted,
        CommitPhase,
        RevealPhase,
        Completed
    }

    struct Player {
        address addr;
        bytes32 commitment;
        Move move;
        bool revealed;
    }

    uint256 public betAmount;
    uint256 public commitDeadline;
    uint256 public revealDeadline;
    GameState public gameState;

    Player[2] public players;
    uint8 public playerCount;

    address public winner;

    event GameStarted(address player1, address player2, uint256 betAmount);
    event MoveCommitted(address player);
    event MoveRevealed(address player, Move move);
    event GameResult(address winner, string result);

    modifier onlyPlayers() {
        require(msg.sender == players[0].addr || msg.sender == players[1].addr, "Not a registered player");
        _;
    }

    modifier inState(GameState _state) {
        require(gameState == _state, "Invalid game state for this action");
        _;
    }

    /**
     * @notice Registers two players and starts the game.
     * @param _player1 Address of the first player.
     * @param _player2 Address of the second player.
     * @param _betAmount Amount each player must bet to participate.
     */
    function startGame(address _player1, address _player2, uint256 _betAmount) external {
        require(gameState == GameState.NotStarted || gameState == GameState.Completed, "Game already in progress");
        require(_player1 != _player2, "Players must be different");

        players[0] = Player({ addr: _player1, commitment: bytes32(0), move: Move.None, revealed: false });
        players[1] = Player({ addr: _player2, commitment: bytes32(0), move: Move.None, revealed: false });
        playerCount = 2;

        betAmount = _betAmount;
        gameState = GameState.CommitPhase;
        commitDeadline = block.timestamp + 5 minutes;

        emit GameStarted(_player1, _player2, _betAmount);
    }

    /**
     * @notice Allows a player to commit their move.
     * @param _commitment Hash of the move and a secret nonce.
     */
    function commitMove(bytes32 _commitment) external payable inState(GameState.CommitPhase) onlyPlayers nonReentrant {
        require(msg.value == betAmount, "Incorrect bet amount");

        Player storage player = getPlayer(msg.sender);
        require(player.commitment == bytes32(0), "Already committed");

        player.commitment = _commitment;
        emit MoveCommitted(msg.sender);

        if (players[0].commitment != bytes32(0) && players[1].commitment != bytes32(0)) {
            gameState = GameState.RevealPhase;
            revealDeadline = block.timestamp + 5 minutes;
        }
    }
}
