// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract NFTRoulette {
    address public owner;
    uint256 public entryFee; // Fee to join the game
    uint256 public currentRound; // Keeps track of game rounds
    uint256 public prizePool; // Total prize pool in ETH
    uint256 public maxRange; // Maximum roulette number
    address public prizeNFTContract; // NFT contract for bonus prize

    struct Entry {
        address player;
        uint256 tokenId;
        uint256 assignedNumber;
    }

    // Entries for each round
    mapping(uint256 => Entry[]) public roundEntries;

    // Events
    event NFTStaked(address indexed player, uint256 tokenId, uint256 round, uint256 assignedNumber);
    event WinnerDeclared(address indexed winner, uint256 tokenId, uint256 prize, uint256 round);

    constructor(uint256 _entryFee, uint256 _maxRange, address _prizeNFTContract) {
        require(_maxRange > 0, "Max range must be greater than zero");
        owner = msg.sender;
        entryFee = _entryFee;
        maxRange = _maxRange;
        prizeNFTContract = _prizeNFTContract;
        currentRound = 1;
    }

    // Stake an NFT and join the game
    function stakeNFT(address nftContract, uint256 tokenId) external payable {
        require(msg.value == entryFee, "Incorrect entry fee");

        // Transfer NFT to the contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Assign a random number to the NFT
        uint256 assignedNumber = tokenId % maxRange;

        // Add to entries
        roundEntries[currentRound].push(Entry(msg.sender, tokenId, assignedNumber));

        // Add to prize pool
        prizePool += msg.value;

        emit NFTStaked(msg.sender, tokenId, currentRound, assignedNumber);
    }

    // Spin the roulette wheel and declare the winner
    function spinRoulette() external onlyOwner {
        require(roundEntries[currentRound].length > 0, "No entries in this round");

        // Generate a random number
        uint256 winningNumber = random() % maxRange;

        // Find the winner
        address winner;
        uint256 winningTokenId;

        for (uint256 i = 0; i < roundEntries[currentRound].length; i++) {
            if (roundEntries[currentRound][i].assignedNumber == winningNumber) {
                winner = roundEntries[currentRound][i].player;
                winningTokenId = roundEntries[currentRound][i].tokenId;
                break;
            }
        }

        // If there's a winner, send the prize
        if (winner != address(0)) {
            uint256 prize = prizePool;
            prizePool = 0;

            // Send prize ETH
            payable(winner).transfer(prize);

            // Bonus NFT prize
            if (prizeNFTContract != address(0)) {
                IERC721(prizeNFTContract).transferFrom(address(this), winner, winningTokenId);
            }

            emit WinnerDeclared(winner, winningTokenId, prize, currentRound);
        }

        // Move to the next round
        currentRound++;
    }

    // Generate pseudo-random number (not secure for production)
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.number)));
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Withdraw remaining prize pool (in case of emergencies)
    function withdrawPool() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
