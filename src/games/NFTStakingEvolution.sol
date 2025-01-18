// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTStakingEvolution is Ownable, IERC721Receiver {
    // NFT Contract being staked
    ERC721 public nftContract;

    // Evolution points earned per day
    uint256 public pointsPerDay = 10;

    // Struct to track staking details
    struct Stake {
        address owner;
        uint256 stakedAt;
        uint256 points;
    }

    // Mapping of tokenId to staking details
    mapping(uint256 => Stake) public stakes;

    // Mapping of tokenId to evolution level
    mapping(uint256 => uint256) public evolutionLevel;

    event NFTStaked(address indexed user, uint256 indexed tokenId, uint256 timestamp);
    event NFTUnstaked(address indexed user, uint256 indexed tokenId, uint256 timestamp);
    event NFTEvolved(address indexed user, uint256 indexed tokenId, uint256 newLevel);

    constructor(address _nftContract) {
        nftContract = ERC721(_nftContract);
    }

    // Stake an NFT
    function stakeNFT(uint256 tokenId) external {
        require(nftContract.ownerOf(tokenId) == msg.sender, "You do not own this NFT");
        require(stakes[tokenId].owner == address(0), "NFT already staked");

        // Transfer NFT to the contract
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);

        // Record stake details
        stakes[tokenId] = Stake({ owner: msg.sender, stakedAt: block.timestamp, points: 0 });

        emit NFTStaked(msg.sender, tokenId, block.timestamp);
    }

    // Unstake an NFT
    function unstakeNFT(uint256 tokenId) external {
        Stake memory stakeInfo = stakes[tokenId];
        require(stakeInfo.owner == msg.sender, "You do not own this staked NFT");

        // Calculate and update evolution points
        stakes[tokenId].points += calculatePoints(tokenId);

        // Reset stake details
        delete stakes[tokenId];

        // Transfer NFT back to the owner
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);

        emit NFTUnstaked(msg.sender, tokenId, block.timestamp);
    }

    // Evolve an NFT
    function evolveNFT(uint256 tokenId) external {
        Stake memory stakeInfo = stakes[tokenId];
        require(stakeInfo.owner == msg.sender, "You do not own this staked NFT");

        // Calculate total evolution points
        uint256 totalPoints = stakeInfo.points + calculatePoints(tokenId);

        // Determine if evolution is possible
        require(
            totalPoints >= getPointsRequiredForEvolution(evolutionLevel[tokenId] + 1), "Not enough points to evolve"
        );

        // Deduct points and increase evolution level
        stakes[tokenId].points = totalPoints - getPointsRequiredForEvolution(evolutionLevel[tokenId] + 1);
        stakes[tokenId].stakedAt = block.timestamp;
        evolutionLevel[tokenId]++;

        emit NFTEvolved(msg.sender, tokenId, evolutionLevel[tokenId]);
    }

    // Calculate earned evolution points
    function calculatePoints(uint256 tokenId) public view returns (uint256) {
        Stake memory stakeInfo = stakes[tokenId];
        if (stakeInfo.owner == address(0)) return 0;
        uint256 stakedDuration = block.timestamp - stakeInfo.stakedAt;
        return (stakedDuration / 1 days) * pointsPerDay;
    }

    // Points required for each evolution level
    function getPointsRequiredForEvolution(uint256 level) public pure returns (uint256) {
        return level * 50; // Example: Level 1 requires 50, Level 2 requires 100, etc.
    }

    // Support for safeTransferFrom
    function onERC721Received(address, address, uint256, bytes memory) public pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // Update points per day (only owner)
    function setPointsPerDay(uint256 _pointsPerDay) external onlyOwner {
        pointsPerDay = _pointsPerDay;
    }
}
