// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @title IERC721 Interface
/// @notice Minimal interface for NFT token interactions
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(address from, address to, uint256 tokenId) external;
}

/**
 * @title NFTRoulette
 * @author CantinaVerse-Tech
 * @notice A decentralized roulette game where players can stake their NFTs for a chance to win prizes
 * @dev Implements a round-based system where players stake NFTs and receive random numbers for winning chances
 */
contract NFTRoulette {
    /// @notice Address of the contract owner
    address public owner;

    /// @notice Structure to store round information
    /// @dev Contains all necessary data for a single game round
    struct Round {
        uint256 entryFee;
        uint256 prizePool;
        uint256 maxRange;
        bool active;
        bool completed;
        Entry[] entries;
    }

    /// @notice Structure to store player entry information
    /// @dev Contains all necessary data for a single player entry
    struct Entry {
        address player;
        uint256 tokenId;
        address nftContract;
        uint256 assignedNumber;
        bool returned;
    }

    /// @notice Mapping of round ID to round data
    mapping(uint256 => Round) public rounds;

    /// @notice Address of the NFT contract used for bonus prizes
    mapping(uint256 => address) public prizeNFTContracts;

    /// @notice Current active round number
    uint256 public currentRound;

    /// @notice Events for tracking game activities
    event RoundCreated(uint256 indexed roundId, uint256 entryFee, uint256 maxRange);
    event NFTStaked(address indexed player, uint256 tokenId, uint256 round, uint256 assignedNumber);
    event WinnerDeclared(address indexed winner, uint256 tokenId, uint256 prize, uint256 round);
    event NFTReturned(address indexed player, uint256 tokenId, uint256 round);

    /// @notice Contract constructor
    /// @param _prizeNFTContract Address of the NFT contract used for bonus prizes
    constructor(address _prizeNFTContract) {
        owner = msg.sender;
        prizeNFTContract = _prizeNFTContract;
        // Start with round 1
        currentRound = 1;
    }

    /// @notice Creates a new game round
    /// @dev Only callable by contract owner
    /// @param _entryFee Amount of ETH required to enter the round
    /// @param _maxRange Maximum range for random number generation
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

    /// @notice Stakes an NFT to participate in a round
    /// @dev Transfers NFT to contract and assigns random number
    /// @param roundId ID of the round to join
    /// @param nftContract Address of the NFT contract
    /// @param tokenId ID of the NFT to stake
    function stakeNFT(uint256 roundId, address nftContract, uint256 tokenId) external payable {
        require(rounds[roundId].active, "Round is not active");
        require(msg.value == rounds[roundId].entryFee, "Incorrect entry fee");

        // Transfer NFT to the contract
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        // Assign a random number to the NFT
        uint256 assignedNumber = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.difficulty, msg.sender, tokenId, rounds[roundId].entries.length)
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

    /// @notice Spins the roulette and determines the winner
    /// @dev Only callable by owner, generates random number and distributes prizes
    /// @param roundId ID of the round to spin
    function spinRoulette(uint256 roundId) external onlyOwner {
        Round storage round = rounds[roundId];
        require(round.active, "Round is not active");
        require(!round.completed, "Round already completed");
        require(round.entries.length > 0, "No entries in this round");

        // Generate a random number
        uint256 winningNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, block.difficulty, roundId, round.entries.length))
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

    /// @notice Returns NFTs to their owners after round completion
    /// @dev Processes NFT returns in batches
    /// @param roundId ID of the completed round
    /// @param startIdx Starting index for batch processing
    /// @param endIdx Ending index for batch processing
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

    /// @notice Retrieves all entries for a specific round
    /// @param roundId ID of the round
    /// @return Array of Entry structs containing player information
    function getRoundEntries(uint256 roundId) external view returns (Entry[] memory) {
        return rounds[roundId].entries;
    }

    /// @notice Retrieves detailed data for a specific round
    /// @param roundId ID of the round
    /// @return entryFee Fee required to enter the round
    /// @return prizePool Total accumulated prize pool
    /// @return maxRange Maximum range for random number generation
    /// @return active Whether the round is currently active
    /// @return completed Whether the round has been completed
    /// @return entriesCount Number of entries in the round
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

    /// @notice Restricts function access to contract owner
    /// @dev Throws if called by any account other than the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /// @notice Emergency function to withdraw all ETH from contract
    /// @dev Only callable by owner, transfers entire balance
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
