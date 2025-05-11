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
}
