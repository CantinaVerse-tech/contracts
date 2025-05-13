// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title RockPaperScissors
 * @author CantinaVerse-Tech
 * @dev A multi-game Rock-Paper-Scissors contract using commit-reveal scheme.
 */
contract RockPaperScissors is ReentrancyGuard {
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

    struct Game {
        uint256 id;
        uint256 betAmount;
        uint256 commitDeadline;
        uint256 revealDeadline;
        GameState state;
        Player[2] players;
        address winner;
    }

    uint256 public nextGameId;
    mapping(uint256 => Game) public games;

    event GameCreated(uint256 indexed gameId, address player1, address player2, uint256 betAmount);
    event MoveCommitted(uint256 indexed gameId, address player);
    event MoveRevealed(uint256 indexed gameId, address player, Move move);
    event GameResult(uint256 indexed gameId, address winner, string result);

    modifier onlyPlayers(uint256 gameId) {
        require(
            msg.sender == games[gameId].players[0].addr || msg.sender == games[gameId].players[1].addr,
            "Not a registered player"
        );
        _;
    }

    modifier inState(uint256 gameId, GameState _state) {
        require(games[gameId].state == _state, "Invalid game state for this action");
        _;
    }

    /**
     * @notice Creates a new game between two players.
     * @param _player1 Address of the first player.
     * @param _player2 Address of the second player.
     * @param _betAmount Amount each player must bet to participate.
     */
    function createGame(address _player1, address _player2, uint256 _betAmount) external {
        require(_player1 != _player2, "Players must be different");

        Game storage game = games[nextGameId];
        game.id = nextGameId;
        game.betAmount = _betAmount;
        game.state = GameState.CommitPhase;
        game.commitDeadline = block.timestamp + 5 minutes;
        game.players[0] = Player({ addr: _player1, commitment: bytes32(0), move: Move.None, revealed: false });
        game.players[1] = Player({ addr: _player2, commitment: bytes32(0), move: Move.None, revealed: false });

        emit GameCreated(nextGameId, _player1, _player2, _betAmount);
        nextGameId++;
    }

    /**
     * @notice Allows a player to commit their move.
     * @param gameId The ID of the game.
     * @param _commitment Hash of the move and a secret nonce.
     */
    function commitMove(
        uint256 gameId,
        bytes32 _commitment
    )
        external
        payable
        inState(gameId, GameState.CommitPhase)
        onlyPlayers(gameId)
        nonReentrant
    {
        Game storage game = games[gameId];
        require(msg.value == game.betAmount, "Incorrect bet amount");

        Player storage player = getPlayer(gameId, msg.sender);
        require(player.commitment == bytes32(0), "Already committed");

        player.commitment = _commitment;
        emit MoveCommitted(gameId, msg.sender);

        if (game.players[0].commitment != bytes32(0) && game.players[1].commitment != bytes32(0)) {
            game.state = GameState.RevealPhase;
            game.revealDeadline = block.timestamp + 5 minutes;
        }
    }

    /**
     * @notice Allows a player to reveal their move.
     * @param _move The move played.
     * @param _nonce The secret nonce used during commitment.
     */
    function revealMove(
        Move _move,
        string calldata _nonce
    )
        external
        inState(GameState.RevealPhase)
        onlyPlayers
        nonReentrant
    {
        require(_move == Move.Rock || _move == Move.Paper || _move == Move.Scissors, "Invalid move");

        Player storage player = getPlayer(msg.sender);
        require(!player.revealed, "Already revealed");
        require(player.commitment != bytes32(0), "No commitment found");

        bytes32 computedHash = keccak256(abi.encodePacked(_move, _nonce));
        require(computedHash == player.commitment, "Commitment mismatch");

        player.move = _move;
        player.revealed = true;
        emit MoveRevealed(msg.sender, _move);

        if (players[0].revealed && players[1].revealed) {
            determineWinner();
        }
    }

    /**
     * @notice Determines the winner and transfers the bet amount.
     */
    function determineWinner() internal {
        Move move1 = players[0].move;
        Move move2 = players[1].move;

        if (move1 == move2) {
            // Draw: refund both players
            payable(players[0].addr).transfer(betAmount);
            payable(players[1].addr).transfer(betAmount);
            emit GameResult(address(0), "Draw");
        } else if (
            (move1 == Move.Rock && move2 == Move.Scissors) || (move1 == Move.Paper && move2 == Move.Rock)
                || (move1 == Move.Scissors && move2 == Move.Paper)
        ) {
            // Player 1 wins
            payable(players[0].addr).transfer(address(this).balance);
            winner = players[0].addr;
            emit GameResult(winner, "Player 1 wins");
        } else {
            // Player 2 wins
            payable(players[1].addr).transfer(address(this).balance);
            winner = players[1].addr;
            emit GameResult(winner, "Player 2 wins");
        }

        gameState = GameState.Completed;
    }

    /**
     * @notice Retrieves the player struct for the given address.
     * @param _addr Address of the player.
     * @return Player struct.
     */
    function getPlayer(address _addr) internal view returns (Player storage) {
        if (players[0].addr == _addr) {
            return players[0];
        } else if (players[1].addr == _addr) {
            return players[1];
        } else {
            revert("Player not found");
        }
    }

    /**
     * @notice Allows a player to claim victory if the opponent fails to reveal in time.
     */
    function claimTimeoutVictory() external inState(GameState.RevealPhase) onlyPlayers nonReentrant {
        require(block.timestamp > revealDeadline, "Reveal phase not over");

        Player storage player = getPlayer(msg.sender);
        Player storage opponent = getPlayer(players[0].addr == msg.sender ? players[1].addr : players[0].addr);

        require(player.revealed && !opponent.revealed, "Cannot claim victory");

        payable(player.addr).transfer(address(this).balance);
        winner = player.addr;
        gameState = GameState.Completed;
        emit GameResult(winner, "Victory by timeout");
    }

    /**
     * @notice Allows a player to withdraw their bet if the opponent fails to commit in time.
     */
    function claimCommitTimeoutRefund() external inState(GameState.CommitPhase) onlyPlayers nonReentrant {
        require(block.timestamp > commitDeadline, "Commit phase not over");

        Player storage player = getPlayer(msg.sender);
        Player storage opponent = getPlayer(players[0].addr == msg.sender ? players[1].addr : players[0].addr);

        require(player.commitment != bytes32(0) && opponent.commitment == bytes32(0), "Cannot claim refund");

        payable(player.addr).transfer(address(this).balance);
        gameState = GameState.Completed;
        emit GameResult(player.addr, "Refund due to opponent's no-show");
    }
}
