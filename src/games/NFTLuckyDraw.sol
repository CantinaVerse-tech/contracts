// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title NFT Lucky Draw
 * @author Catinaverse-Tech
 * @notice A Lucky Draw platform supporting multiple game instances
 * @dev Random winners are selected based on block data, pseudo-randomly.
 * @dev Chainlink VRF is recommended for true-randomness in production.
 */
contract NFTLuckyDraw is ERC721Enumerable, Ownable {
    /// @notice Default mint fee
    uint256 public defaultMintFee = 0.0001 ether;

    /// @notice Game struct to hold individual game data
    struct Game {
        uint256 gameId;
        uint256 mintFee;
        uint256 prizePool;
        bool active;
        uint256 startTokenId;
        uint256 endTokenId;
        address winner;
        bool prizeDistributed;
    }

    /// @notice Map of gameId to Game data
    mapping(uint256 => Game) public games;

    /// @notice Total number of games created
    uint256 public totalGames;

    /// @notice Maps tokenId to gameId
    mapping(uint256 => uint256) public tokenGameId;

    event GameCreated(uint256 indexed gameId, uint256 mintFee);
    event GameStopped(uint256 indexed gameId);
    event Mint(address indexed player, uint256 tokenId, uint256 gameId);
    event WinnerSelected(uint256 indexed gameId, address indexed winner, uint256 tokenId, uint256 prize);

    constructor() ERC721("LuckyDrawNFT", "LDNFT") {
        // Create the first game
        _createGame(defaultMintFee);
    }

    /**
     * @notice Create a new game instance
     * @param mintFee_ The mint fee for this specific game
     * @return gameId The ID of the newly created game
     */
    function createGame(uint256 mintFee_) external onlyOwner returns (uint256) {
        return _createGame(mintFee_);
    }

    /**
     * @notice Internal function to create a new game
     * @param mintFee_ The mint fee for this specific game
     * @return gameId The ID of the newly created game
     */
    function _createGame(uint256 mintFee_) internal returns (uint256) {
        totalGames++;
        uint256 gameId = totalGames;

        games[gameId] = Game({
            gameId: gameId,
            mintFee: mintFee_,
            prizePool: 0,
            active: true,
            startTokenId: totalSupply() + 1,
            endTokenId: 0,
            winner: address(0),
            prizeDistributed: false
        });

        emit GameCreated(gameId, mintFee_);
        return gameId;
    }

    /**
     * @notice Mint a new Lucky Draw NFT for a specific game
     * @param gameId The ID of the game to mint for
     * @return tokenId The ID of the newly minted token
     */
    function mintLuckyCard(uint256 gameId) external payable returns (uint256 tokenId) {
        require(gameId > 0 && gameId <= totalGames, "Invalid game ID");
        Game storage game = games[gameId];
        require(game.active, "Game is not active");
        require(msg.value == game.mintFee, "Incorrect mint fee");

        tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);

        // Associate token with game
        tokenGameId[tokenId] = gameId;

        // Update game data
        game.prizePool += msg.value;
        if (game.endTokenId == 0 || tokenId > game.endTokenId) {
            game.endTokenId = tokenId;
        }

        emit Mint(msg.sender, tokenId, gameId);
    }

    /**
     * @notice Select a random winner for a specific game
     * @param gameId The ID of the game to select a winner for
     * @return winner The address of the selected winner
     */
    function selectWinner(uint256 gameId) external onlyOwner returns (address winner) {
        require(gameId > 0 && gameId <= totalGames, "Invalid game ID");
        Game storage game = games[gameId];
        require(game.active, "Game is not active");
        require(game.startTokenId <= game.endTokenId, "No NFTs minted for this game");
        require(game.prizePool > 0, "No prize pool available");
        require(!game.prizeDistributed, "Prize already distributed");

        uint256 tokenCount = game.endTokenId - game.startTokenId + 1;
        require(tokenCount > 0, "No tokens in this game");

        // Pseudo-random number based on block data
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, gameId, tokenCount)));
        uint256 winningTokenId = game.startTokenId + (random % tokenCount);

        // Ensure the token belongs to this game (in case of any edge cases)
        require(tokenGameId[winningTokenId] == gameId, "Token not in this game");

        winner = ownerOf(winningTokenId);
        game.winner = winner;

        // Transfer the prize pool to the winner
        uint256 prize = game.prizePool;
        game.prizePool = 0;
        game.prizeDistributed = true;

        (bool success,) = payable(winner).call{ value: prize }("");
        require(success, "Transfer to winner failed");

        emit WinnerSelected(gameId, winner, winningTokenId, prize);
    }

    /**
     * @notice Stop a specific game
     * @param gameId The ID of the game to stop
     */
    function stopGame(uint256 gameId) external onlyOwner {
        require(gameId > 0 && gameId <= totalGames, "Invalid game ID");
        Game storage game = games[gameId];
        require(game.active, "Game already stopped");

        game.active = false;
        emit GameStopped(gameId);
    }

    /**
     * @notice Get active games
     * @return activeGameIds Array of active game IDs
     */
    function getActiveGames() external view returns (uint256[] memory activeGameIds) {
        uint256 activeCount = 0;

        // First, count active games
        for (uint256 i = 1; i <= totalGames; i++) {
            if (games[i].active) {
                activeCount++;
            }
        }

        // Then populate the array
        activeGameIds = new uint256[](activeCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= totalGames; i++) {
            if (games[i].active) {
                activeGameIds[index] = i;
                index++;
            }
        }
    }

    /**
     * @notice Get game details
     * @param gameId The ID of the game to get details for
     * @return Game struct with game details
     */
    function getGameDetails(uint256 gameId) external view returns (Game memory) {
        require(gameId > 0 && gameId <= totalGames, "Invalid game ID");
        return games[gameId];
    }

    /**
     * @notice Withdraw owner fees (contract balance - all prize pools)
     */
    function withdrawOwnerFees() external onlyOwner {
        uint256 totalPrizePool = 0;

        for (uint256 i = 1; i <= totalGames; i++) {
            totalPrizePool += games[i].prizePool;
        }

        uint256 ownerFees = address(this).balance - totalPrizePool;
        require(ownerFees > 0, "No fees to withdraw");

        payable(owner()).transfer(ownerFees);
    }

    // Receive fallback
    receive() external payable { }
}
