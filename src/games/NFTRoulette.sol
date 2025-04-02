// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract ImprovedNFTRoulette {
    address public owner;
    address public prizeNFTContract; // NFT contract for bonus prize

    struct Round {
        uint256 entryFee;
        uint256 prizePool;
        uint256 maxRange;
        bool active;
        bool completed;
        Entry[] entries;
    }

    struct Entry {
        address player;
        uint256 tokenId;
        address nftContract;
        uint256 assignedNumber;
        bool returned;
    }

    // Rounds data
    mapping(uint256 => Round) public rounds;
    uint256 public currentRound;

    // Events
    event RoundCreated(uint256 indexed roundId, uint256 entryFee, uint256 maxRange);
    event NFTStaked(address indexed player, uint256 tokenId, uint256 round, uint256 assignedNumber);
    event WinnerDeclared(address indexed winner, uint256 tokenId, uint256 prize, uint256 round);
    event NFTReturned(address indexed player, uint256 tokenId, uint256 round);

    constructor(address _prizeNFTContract) {
        owner = msg.sender;
        prizeNFTContract = _prizeNFTContract;
        // Start with round 1
        currentRound = 1;
    }

    // Create a new round
    function createRound(uint256 _entryFee, uint256 _maxRange) external onlyOwner {
        require(_maxRange > 0, "Max range must be greater than zero");

        rounds[currentRound] = Round({
            entryFee: _entryFee,
            prizePool: 0,
            maxRange: _maxRange,
            active: true,
            completed: false,
            entries: new Entry[](0)
        });

        emit RoundCreated(currentRound, _entryFee, _maxRange);
    }

    // Stake an NFT and join the game
    function stakeNFT(uint256 roundId, address nftContract, uint256 tokenId) external payable {
        require(rounds[roundId].active, "Round is not active");
        require(msg.value == rounds[roundId].entryFee, "Incorrect entry fee");

        // Transfer NFT to the contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Assign a random number to the NFT
        uint256 assignedNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, tokenId, rounds[roundId].entries.length)
            )
        ) % rounds[roundId].maxRange;

        // Add to entries
        rounds[roundId].entries.push(
            Entry({
                player: msg.sender,
                tokenId: tokenId,
                nftContract: nftContract,
                assignedNumber: assignedNumber,
                returned: false
            })
        );

        // Add to prize pool
        rounds[roundId].prizePool += msg.value;

        emit NFTStaked(msg.sender, tokenId, roundId, assignedNumber);
    }

    // Spin the roulette wheel and declare the winner
    function spinRoulette(uint256 roundId) external onlyOwner {
        Round storage round = rounds[roundId];
        require(round.active, "Round is not active");
        require(!round.completed, "Round already completed");
        require(round.entries.length > 0, "No entries in this round");

        // Generate a random number
        uint256 winningNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.prevrandao, roundId, round.entries.length))
        ) % round.maxRange;

        // Find the winner
        address winner = address(0);
        uint256 winningTokenId;
        address winningNFTContract;
        uint256 winningIndex;

        for (uint256 i = 0; i < round.entries.length; i++) {
            if (round.entries[i].assignedNumber == winningNumber) {
                winner = round.entries[i].player;
                winningTokenId = round.entries[i].tokenId;
                winningNFTContract = round.entries[i].nftContract;
                winningIndex = i;
                break;
            }
        }

        // If there's a winner, send the prize
        if (winner != address(0)) {
            uint256 prize = round.prizePool;
            round.prizePool = 0;

            // Send prize ETH
            payable(winner).transfer(prize);

            // Return the winning NFT to the owner
            IERC721(winningNFTContract).transferFrom(address(this), winner, winningTokenId);
            round.entries[winningIndex].returned = true;

            // Bonus NFT prize if available
            if (prizeNFTContract != address(0)) {
                // This assumes the contract owns prize NFTs it can distribute
                try IERC721(prizeNFTContract).transferFrom(address(this), winner, winningTokenId) {
                    // Success - bonus NFT transferred
                } catch {
                    // Failed to transfer bonus NFT - could be handled differently
                }
            }

            emit WinnerDeclared(winner, winningTokenId, prize, roundId);
        }

        // Mark round as completed
        round.active = false;
        round.completed = true;

        // Prepare for next round
        currentRound++;
    }

    // Return NFTs to their owners for a completed round (except the winning NFT which is already returned)
    function returnNFTs(uint256 roundId, uint256 startIdx, uint256 endIdx) external {
        Round storage round = rounds[roundId];
        require(!round.active, "Round is still active");
        require(round.completed, "Round not completed yet");

        if (endIdx > round.entries.length) {
            endIdx = round.entries.length;
        }

        for (uint256 i = startIdx; i < endIdx; i++) {
            Entry storage entry = round.entries[i];
            if (!entry.returned) {
                IERC721(entry.nftContract).transferFrom(address(this), entry.player, entry.tokenId);
                entry.returned = true;

                emit NFTReturned(entry.player, entry.tokenId, roundId);
            }
        }
    }

    // Get all entries for a specific round
    function getRoundEntries(uint256 roundId) external view returns (Entry[] memory) {
        return rounds[roundId].entries;
    }

    // Get round data
    function getRoundData(uint256 roundId)
        external
        view
        returns (
            uint256 entryFee,
            uint256 prizePool,
            uint256 maxRange,
            bool active,
            bool completed,
            uint256 entriesCount
        )
    {
        Round storage round = rounds[roundId];
        return (round.entryFee, round.prizePool, round.maxRange, round.active, round.completed, round.entries.length);
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Emergency function to withdraw ETH
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
