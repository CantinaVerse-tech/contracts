// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Lucky Draw Game.
 * @author Catinaverse-Tech.
 * @notice A simple Lucky Draw game for minting and selecting a random winner.
 * @dev Random winners are selected based on block data, pseudo-randomly.
 * @dev Chainlink VRF is used for true-randomness, which is in the future scope of this contract.
 */

contract LuckyDrawGame is ERC721Enumerable, Ownable {
    /// @notice Mint fee.
    uint256 public mintFee = 0.0001 ether;
    /// @notice Prize pool, collected by minting fee for lucky card NFT.
    uint256 public prizePool = 0;
    /// @notice Game is active or ended bool.
    bool public gameActive = true;

    event Mint(address indexed player, uint256 tokenId);
    event WinnerSelected(
        address indexed winner,
        uint256 tokenId,
        uint256 prize
    );

    constructor() ERC721("LuckyDrawNFT", "LDNFT") {}

    // Mint a new Lucky Draw NFT
    function mintLuckyCard() external payable {
        require(gameActive, "Game is not active");
        require(msg.value == mintFee, "Incorrect mint fee");

        uint256 tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);

        prizePool += msg.value;

        emit Mint(msg.sender, tokenId);
    }

    // Select a random winner
    function selectWinner() external onlyOwner {
        require(totalSupply() > 0, "No NFTs minted");
        require(prizePool > 0, "No prize pool available");

        // Pseudo-random number based on block data
        uint256 random = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.prevrandao,
                    totalSupply()
                )
            )
        );
        uint256 winningTokenId = (random % totalSupply()) + 1;

        address winner = ownerOf(winningTokenId);

        // Transfer the prize pool to the winner
        uint256 prize = prizePool;
        prizePool = 0;
        payable(winner).transfer(prize);

        emit WinnerSelected(winner, winningTokenId, prize);
    }

    // Stop the game (optional)
    function stopGame() external onlyOwner {
        gameActive = false;
    }

    // Withdraw remaining funds (owner fees)
    function withdrawOwnerFees() external onlyOwner {
        uint256 balance = address(this).balance - prizePool;
        require(balance > 0, "No fees to withdraw");
        payable(owner()).transfer(balance);
    }

    // Receive fallback
    receive() external payable {}
}
