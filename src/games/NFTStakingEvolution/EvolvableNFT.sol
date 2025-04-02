// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title EvolvableNFT
 * @author Catinaverse-Tech
 * @dev NFT contract designed to work with the NFTStakingEvolution contract
 */
contract EvolvableNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    // Token ID counter
    Counters.Counter private _tokenIdCounter;

    // Base URI for metadata
    string private _baseTokenURI;

    // Maximum supply of NFTs
    uint256 public maxSupply = 10_000;

    // Mint price
    uint256 public mintPrice = 0.01 ether;

    // Mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    // Authorized evolution contract
    address public evolutionContract;

    // NFT attributes
    struct NFTAttributes {
        string species;
        uint256 rarity; // 1 = common, 2 = uncommon, 3 = rare, 4 = epic, 5 = legendary
        uint256 createdAt;
    }

    // Mapping of token ID to attributes
    mapping(uint256 => NFTAttributes) public tokenAttributes;

    // Available species
    string[] public availableSpecies = ["Dragon", "Phoenix", "Griffin", "Unicorn", "Hydra"];

    // Events
    event NFTMinted(address indexed to, uint256 indexed tokenId, string species, uint256 rarity);
    event EvolutionContractUpdated(address indexed evolutionContract);

    /**
     * @dev Constructor sets name, symbol, and base URI
     */
    constructor(string memory baseURI) ERC721("Evolvable Creatures", "EVOLVE") {
        _baseTokenURI = baseURI;
    }

    /**
     * @dev Mint a new NFT
     * @param species The species of the NFT (must be one from availableSpecies)
     * @return tokenId The ID of the minted token
     */
    function mint(string memory species) external payable returns (uint256) {
        require(totalSupply() < maxSupply, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");
        require(isValidSpecies(species), "Invalid species");

        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        // Determine rarity (pseudo-random)
        uint256 rarity = determineRarity();

        // Set attributes
        tokenAttributes[tokenId] = NFTAttributes({ species: species, rarity: rarity, createdAt: block.timestamp });

        _mint(msg.sender, tokenId);

        emit NFTMinted(msg.sender, tokenId, species, rarity);

        return tokenId;
    }

    /**
     * @dev Mint multiple NFTs at once
     * @param amount Number of NFTs to mint
     * @param species The species for all NFTs
     * @return firstTokenId The ID of the first minted token
     */
    function mintBatch(uint256 amount, string memory species) external payable returns (uint256) {
        require(totalSupply() + amount <= maxSupply, "Would exceed max supply");
        require(msg.value >= mintPrice * amount, "Insufficient payment");
        require(isValidSpecies(species), "Invalid species");

        uint256 firstTokenId = _tokenIdCounter.current() + 1;

        for (uint256 i = 0; i < amount; i++) {
            _tokenIdCounter.increment();
            uint256 tokenId = _tokenIdCounter.current();

            // Determine rarity (pseudo-random)
            uint256 rarity = determineRarity();

            // Set attributes
            tokenAttributes[tokenId] = NFTAttributes({ species: species, rarity: rarity, createdAt: block.timestamp });

            _mint(msg.sender, tokenId);

            emit NFTMinted(msg.sender, tokenId, species, rarity);
        }

        return firstTokenId;
    }

    /**
     * @dev Determines the rarity of a new NFT
     * @return Rarity level (1-5)
     */
    function determineRarity() internal view returns (uint256) {
        uint256 randomValue =
            uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, totalSupply()))) % 100;

        // 60% common, 25% uncommon, 10% rare, 4% epic, 1% legendary
        if (randomValue < 60) {
            return 1; // Common
        } else if (randomValue < 85) {
            return 2; // Uncommon
        } else if (randomValue < 95) {
            return 3; // Rare
        } else if (randomValue < 99) {
            return 4; // Epic
        } else {
            return 5; // Legendary
        }
    }

    /**
     * @dev Checks if a species is valid
     * @param species Species to check
     * @return bool Whether the species is valid
     */
    function isValidSpecies(string memory species) public view returns (bool) {
        for (uint256 i = 0; i < availableSpecies.length; i++) {
            if (keccak256(bytes(availableSpecies[i])) == keccak256(bytes(species))) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Set the evolution contract address
     * @param _evolutionContract Address of the NFTStakingEvolution contract
     */
    function setEvolutionContract(address _evolutionContract) external onlyOwner {
        require(_evolutionContract != address(0), "Invalid evolution contract address");
        evolutionContract = _evolutionContract;
        emit EvolutionContractUpdated(_evolutionContract);
    }

    /**
     * @dev Add a new species to the available list
     * @param species New species to add
     */
    function addSpecies(string memory species) external onlyOwner {
        require(!isValidSpecies(species), "Species already exists");
        availableSpecies.push(species);
    }

    /**
     * @dev Remove a species from the available list
     * @param species Species to remove
     */
    function removeSpecies(string memory species) external onlyOwner {
        require(isValidSpecies(species), "Species does not exist");

        uint256 index;
        bool found = false;

        for (uint256 i = 0; i < availableSpecies.length; i++) {
            if (keccak256(bytes(availableSpecies[i])) == keccak256(bytes(species))) {
                index = i;
                found = true;
                break;
            }
        }

        if (found) {
            // Swap with the last element and pop
            availableSpecies[index] = availableSpecies[availableSpecies.length - 1];
            availableSpecies.pop();
        }
    }

    /**
     * @dev Set a new base URI for all token metadata
     * @param baseURI_ New base URI
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseTokenURI = baseURI_;
    }

    /**
     * @dev Set a specific URI for a token
     * @param tokenId Token ID to set URI for
     * @param _tokenURI URI to set
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) external {
        require(_exists(tokenId), "Token does not exist");
        require(msg.sender == owner() || msg.sender == evolutionContract, "Not authorized");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Override tokenURI function to return specific URI if set
     * @param tokenId Token ID to get URI for
     * @return Token URI string
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];

        // If token has a specific URI set, return it
        if (bytes(_tokenURI).length > 0) {
            return _tokenURI;
        }

        // Otherwise use base URI + token ID + evolution level
        uint256 level = 0;
        if (evolutionContract != address(0)) {
            try NFTStakingEvolution(evolutionContract).evolutionLevel(tokenId) returns (uint256 _level) {
                level = _level;
            } catch {
                // If call fails, level remains 0
            }
        }

        NFTAttributes memory attrs = tokenAttributes[tokenId];

        return string(
            abi.encodePacked(
                _baseURI(),
                tokenId.toString(),
                "?species=",
                attrs.species,
                "&rarity=",
                attrs.rarity.toString(),
                "&level=",
                level.toString()
            )
        );
    }

    /**
     * @dev Get available species
     * @return Array of available species
     */
    function getAvailableSpecies() external view returns (string[] memory) {
        return availableSpecies;
    }

    /**
     * @dev Base URI for computing tokenURI
     * @return Base URI string
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Update mint price
     * @param _mintPrice New mint price
     */
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    /**
     * @dev Update max supply
     * @param _maxSupply New max supply
     */
    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        require(_maxSupply >= totalSupply(), "New max supply below current supply");
        maxSupply = _maxSupply;
    }

    /**
     * @dev Withdraw contract balance to owner
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }
}

// Interface for the NFTStakingEvolution contract
interface NFTStakingEvolution {
    function evolutionLevel(uint256 tokenId) external view returns (uint256);
}
