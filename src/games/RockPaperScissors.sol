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
}
