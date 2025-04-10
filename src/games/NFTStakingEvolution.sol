// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title NFT Staking Evolution Contract
/// @notice A contract that allows users to stake NFTs and earn evolution points over time
/// @dev Implements staking mechanics with evolution system and point-based upgrades
contract NFTStakingEvolution is Ownable, IERC721Receiver {
    /// @notice The NFT contract that can be staked in this contract
    ERC721 public nftContract;

    /// @notice Number of evolution points earned per day of staking
    /// @dev Default value is 10 points per day
    uint256 public pointsPerDay = 10;

    /// @notice Structure to track staking information for each NFT
    /// @dev Contains owner address, stake timestamp, and accumulated points
    struct Stake {
        address owner; /// @notice Address of the NFT staker
        uint256 stakedAt; /// @notice Timestamp when the NFT was staked
        uint256 points; /// @notice Accumulated evolution points
    }

    /// @notice Mapping from token ID to its staking information
    mapping(uint256 => Stake) public stakes;

    /// @notice Mapping from token ID to its current evolution level
    mapping(uint256 => uint256) public evolutionLevel;

    /// @notice Emitted when an NFT is staked
    /// @param user Address of the user who staked the NFT
    /// @param tokenId ID of the staked NFT
    /// @param timestamp Time when the NFT was staked
    event NFTStaked(
        address indexed user,
        uint256 indexed tokenId,
        uint256 timestamp
    );

    /// @notice Emitted when an NFT is unstaked
    /// @param user Address of the user who unstaked the NFT
    /// @param tokenId ID of the unstaked NFT
    /// @param timestamp Time when the NFT was unstaked
    event NFTUnstaked(
        address indexed user,
        uint256 indexed tokenId,
        uint256 timestamp
    );

    /// @notice Emitted when an NFT evolves to a new level
    /// @param user Address of the NFT owner
    /// @param tokenId ID of the evolved NFT
    /// @param newLevel New evolution level of the NFT
    event NFTEvolved(
        address indexed user,
        uint256 indexed tokenId,
        uint256 newLevel
    );

    /// @notice Contract constructor
    /// @param _nftContract Address of the NFT contract that can be staked
    constructor(address _nftContract) {
        nftContract = ERC721(_nftContract);
    }

    /// @notice Stakes an NFT in the contract
    /// @dev Transfers NFT to contract and initializes staking details
    /// @param tokenId ID of the NFT to stake
    function stakeNFT(uint256 tokenId) external {
        require(
            nftContract.ownerOf(tokenId) == msg.sender,
            "You do not own this NFT"
        );
        require(stakes[tokenId].owner == address(0), "NFT already staked");

        // Transfer NFT to the contract
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        // Record stake details
        stakes[tokenId] = Stake({
            owner: msg.sender,
            stakedAt: block.timestamp,
            points: 0
        });

        emit NFTStaked(msg.sender, tokenId, block.timestamp);
    }

    /// @notice Unstakes an NFT and returns it to the owner
    /// @dev Calculates final points and transfers NFT back
    /// @param tokenId ID of the NFT to unstake
    function unstakeNFT(uint256 tokenId) external {
        Stake memory stakeInfo = stakes[tokenId];
        require(
            stakeInfo.owner == msg.sender,
            "You do not own this staked NFT"
        );

        // Calculate and update evolution points
        stakes[tokenId].points += calculatePoints(tokenId);

        // Reset stake details
        delete stakes[tokenId];

        // Transfer NFT back to the owner
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTUnstaked(msg.sender, tokenId, block.timestamp);
    }

    /// @notice Evolves an NFT to the next level if enough points are accumulated
    /// @dev Deducts required points and increases evolution level
    /// @param tokenId ID of the NFT to evolve
    function evolveNFT(uint256 tokenId) external {
        Stake memory stakeInfo = stakes[tokenId];
        require(
            stakeInfo.owner == msg.sender,
            "You do not own this staked NFT"
        );

        // Calculate total evolution points
        uint256 totalPoints = stakeInfo.points + calculatePoints(tokenId);

        // Determine if evolution is possible
        require(
            totalPoints >=
                getPointsRequiredForEvolution(evolutionLevel[tokenId] + 1),
            "Not enough points to evolve"
        );

        // Deduct points and increase evolution level
        stakes[tokenId].points =
            totalPoints -
            getPointsRequiredForEvolution(evolutionLevel[tokenId] + 1);
        stakes[tokenId].stakedAt = block.timestamp;
        evolutionLevel[tokenId]++;

        emit NFTEvolved(msg.sender, tokenId, evolutionLevel[tokenId]);
    }

    /// @notice Calculates evolution points earned by an NFT
    /// @dev Points are based on staking duration and points per day rate
    /// @param tokenId ID of the NFT to calculate points for
    /// @return uint256 Number of evolution points earned
    function calculatePoints(uint256 tokenId) public view returns (uint256) {
        Stake memory stakeInfo = stakes[tokenId];
        if (stakeInfo.owner == address(0)) return 0;
        uint256 stakedDuration = block.timestamp - stakeInfo.stakedAt;
        return (stakedDuration / 1 days) * pointsPerDay;
    }

    /// @notice Calculates points required for a specific evolution level
    /// @dev Each level requires more points than the previous
    /// @param level Evolution level to calculate points for
    /// @return uint256 Number of points required for the specified level
    function getPointsRequiredForEvolution(
        uint256 level
    ) public pure returns (uint256) {
        return level * 50; // Example: Level 1 requires 50, Level 2 requires 100, etc.
    }

    /// @notice Handles the receipt of an NFT
    /// @dev Implementation of IERC721Receiver interface
    /// @return bytes4 Function selector to indicate successful receipt
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    /// @notice Updates the number of points earned per day
    /// @dev Only callable by contract owner
    /// @param _pointsPerDay New points per day value
    function setPointsPerDay(uint256 _pointsPerDay) external onlyOwner {
        pointsPerDay = _pointsPerDay;
    }
}
