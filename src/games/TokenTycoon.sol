// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

// Import OpenZeppelin Contracts
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TokenTycoon
 * @author CantinaVerse-Tech
 * @dev A simulation game where players manage factories to produce and trade tokens.
 */
contract TokenTycoon is ERC20, Ownable, ReentrancyGuard {
    using Address for address payable;

    // Constants
    uint256 public constant FACTORY_BASE_COST = 0 ether;
    uint256 public constant UPGRADE_COST = 0 ether;
    uint256 public constant BASE_PRODUCTION_RATE = 0 ether; // Tokens per day
    uint256 public constant UPGRADE_PRODUCTION_INCREMENT = 0 ether; // Additional tokens per upgrade per day

    // Player structure
    struct Player {
        uint256 factoryCount;
        uint256 upgradeLevel;
        uint256 lastClaimTime;
        uint256 unclaimedTokens;
    }

    // Mapping from player address to their data
    mapping(address => Player) public players;

    // Events
    event FactoryPurchased(address indexed player, uint256 newFactoryCount);
    event FactoryUpgraded(address indexed player, uint256 newUpgradeLevel);
    event TokensClaimed(address indexed player, uint256 amount);
    event TokensWithdrawn(address indexed player, uint256 amount);

    /**
     * @dev Constructor that initializes the ERC20 token with name and symbol.
     */
    constructor() ERC20("TycoonToken", "TYC") { }

    /**
     * @notice Allows a player to purchase a new factory.
     * @dev Requires payment of FACTORY_BASE_COST in ETH.
     */
    function purchaseFactory() external payable nonReentrant {
        require(msg.value == FACTORY_BASE_COST, "Incorrect ETH amount sent");

        Player storage player = players[msg.sender];
        _updateUnclaimedTokens(msg.sender);

        player.factoryCount += 1;
        emit FactoryPurchased(msg.sender, player.factoryCount);
    }

    /**
     * @notice Allows a player to upgrade their factories.
     * @dev Requires payment of UPGRADE_COST in ETH.
     */
    function upgradeFactory() external payable nonReentrant {
        require(msg.value == UPGRADE_COST, "Incorrect ETH amount sent");

        Player storage player = players[msg.sender];
        require(player.factoryCount > 0, "No factories to upgrade");

        _updateUnclaimedTokens(msg.sender);

        player.upgradeLevel += 1;
        emit FactoryUpgraded(msg.sender, player.upgradeLevel);
    }

    /**
     * @notice Allows a player to claim their accumulated tokens.
     */
    function claimTokens() external nonReentrant {
        _updateUnclaimedTokens(msg.sender);

        Player storage player = players[msg.sender];
        uint256 amount = player.unclaimedTokens;
        require(amount > 0, "No tokens to claim");

        player.unclaimedTokens = 0;
        _mint(msg.sender, amount);
        emit TokensClaimed(msg.sender, amount);
    }

    /**
     * @notice Allows a player to withdraw their tokens for ETH.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawTokens(uint256 amount) external nonReentrant {
        require(balanceOf(msg.sender) >= amount, "Insufficient token balance");

        // Define the exchange rate: 1 TYC = 0.01 ETH
        uint256 ethAmount = (amount * 1 ether) / 100;

        require(address(this).balance >= ethAmount, "Contract has insufficient ETH");

        _burn(msg.sender, amount);
        payable(msg.sender).sendValue(ethAmount);
        emit TokensWithdrawn(msg.sender, amount);
    }

    /**
     * @dev Internal function to update a player's unclaimed tokens based on time elapsed.
     * @param playerAddr The address of the player.
     */
    function _updateUnclaimedTokens(address playerAddr) internal {
        Player storage player = players[playerAddr];

        uint256 currentTime = block.timestamp;
        uint256 lastTime = player.lastClaimTime;

        if (lastTime == 0) {
            player.lastClaimTime = currentTime;
            return;
        }

        uint256 timeElapsed = currentTime - lastTime;
        if (timeElapsed == 0) {
            return;
        }

        uint256 productionRatePerSecond = (
            (BASE_PRODUCTION_RATE + (player.upgradeLevel * UPGRADE_PRODUCTION_INCREMENT)) * player.factoryCount
        ) / 1 days;
        uint256 tokensProduced = productionRatePerSecond * timeElapsed;

        player.unclaimedTokens += tokensProduced;
        player.lastClaimTime = currentTime;
    }
}
