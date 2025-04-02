// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PrizeNFT
 * @author CantinaVerse-Tech
 * @dev ERC721 contract for prize NFTs awarded in the NFT Roulette game
 */
contract PrizeNFT is ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;

    // Token counter
    Counters.Counter private _tokenIdCounter;

    // Base URI for token metadata
    string private _baseTokenURI;

    // Mapping to store prize tiers for each token
    mapping(uint256 => uint256) public prizeTier;

    // Authorized game contracts that can mint prizes
    mapping(address => bool) public authorizedGames;

    // Events
    event GameAuthorized(address gameContract);
    event GameRevoked(address gameContract);
    event PrizeNFTMinted(address to, uint256 tokenId, uint256 tier);

    /**
     * @dev Constructor initializes the contract with name and symbol
     * @param name_ Name of the NFT collection
     * @param symbol_ Symbol of the NFT collection
     * @param baseURI_ Base URI for token metadata
     */
    constructor(string memory name_, string memory symbol_, string memory baseURI_) ERC721(name_, symbol_) {
        _baseTokenURI = baseURI_;
    }

    /**
     * @dev Authorize a game contract to mint prize NFTs
     * @param gameContract Address of the game contract to authorize
     */
    function authorizeGame(address gameContract) external onlyOwner {
        require(gameContract != address(0), "Invalid game address");
        authorizedGames[gameContract] = true;
        emit GameAuthorized(gameContract);
    }

    /**
     * @dev Revoke authorization from a game contract
     * @param gameContract Address of the game contract to revoke
     */
    function revokeGame(address gameContract) external onlyOwner {
        authorizedGames[gameContract] = false;
        emit GameRevoked(gameContract);
    }

    /**
     * @dev Mint a new prize NFT
     * @param to Address to mint the NFT to
     * @param tier Prize tier (1 = common, 2 = uncommon, 3 = rare, etc.)
     * @return tokenId ID of the minted token
     */
    function mintPrize(address to, uint256 tier) external returns (uint256) {
        require(authorizedGames[msg.sender] || owner() == msg.sender, "Not authorized to mint");
        require(to != address(0), "Cannot mint to zero address");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _mint(to, tokenId);
        prizeTier[tokenId] = tier;

        emit PrizeNFTMinted(to, tokenId, tier);

        return tokenId;
    }

    /**
     * @dev Mint multiple prize NFTs to a contract for later distribution
     * @param to Address to mint the NFTs to (usually the game contract)
     * @param amount Number of NFTs to mint
     * @param tier Prize tier (1 = common, 2 = uncommon, 3 = rare, etc.)
     * @return firstTokenId ID of the first minted token
     */
    function mintBatch(address to, uint256 amount, uint256 tier) external onlyOwner returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");

        uint256 firstTokenId = _tokenIdCounter.current() + 1;

        for (uint256 i = 0; i < amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();

            _mint(to, tokenId);
            prizeTier[tokenId] = tier;

            emit PrizeNFTMinted(to, tokenId, tier);
        }

        return firstTokenId;
    }

    /**
     * @dev Get the prize tier of a token
     * @param tokenId Token ID to query
     * @return Tier of the prize (1 = common, 2 = uncommon, 3 = rare, etc.)
     */
    function getPrizeTier(uint256 tokenId) external view returns (uint256) {
        require(_exists(tokenId), "Token does not exist");
        return prizeTier[tokenId];
    }

    /**
     * @dev Set the base URI for token metadata
     * @param baseURI_ New base URI
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseTokenURI = baseURI_;
    }

    /**
     * @dev Base URI for computing {tokenURI}
     * @return baseURI string
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}
