// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { ILiquidityManager } from "./interfaces/ILiquidityManager.sol";
import { IVestingVault } from "./interfaces/IVestingVault.sol";

contract PresaleManager is Ownable {
    // @notice The address of the USDT token
    IERC20 public immutable usdt;

    // @notice The token being held in the vault
    IERC20 public immutable token;

    // @notice The VestingVault contract
    address public immutable vault;

    // @notice The LiquidityManager contract
    address public immutable liquidityManager;

    // @notice The price of the token
    uint256 public immutable tokenPrice = 0.5e6; // $0.50 (6 decimals)

    // @notice The amount of USDT allocated to each user
    uint256 public immutable allocationPerUser = 100e6; // $100 USDT

    // @notice The maximum number of users
    uint256 public immutable maxUsers = 100;

    // @notice The minimum cap
    uint256 public immutable minCap = 5000e6; // $5,000 USDT

    // @notice The maximum cap
    uint256 public totalRaised;

    // @notice The total number of participants
    uint256 public totalParticipants;

    // @notice The finalization status
    bool public finalized;

    // @notice Refunded users
    bool public refundsEnabled;

    // @notice The whitelist status
    mapping(address => bool) public whitelisted;

    // @notice The participation status
    mapping(address => bool) public hasParticipated;

    // @notice The refund status
    mapping(address => bool) public refunded;

    // @notice The participants
    address[] public participants;

    // Events
    // @notice Emitted when a user deposits
    event Deposited(address indexed user, uint256 usdtAmount, uint256 tokenAmount);

    // @notice Emitted when the presale is finalized
    event Finalized(uint256 totalUSDT, uint256 totalTokens);

    // @notice Emitted when a user is refunded
    event Refunded(address indexed user, uint256 amount);

    /**
     * @notice Constructor to initialize the contract
     * @param _usdt The address of the USDT token
     * @param _token The token being held in the vault
     * @param _vestingVault The VestingVault contract
     * @param _liquidityManager The LiquidityManager contract
     */
    constructor(address _usdt, address _token, address _vestingVault, address _liquidityManager) {
        usdt = IERC20(_usdt);
        token = IERC20(_token);
        vault = _vestingVault;
        liquidityManager = _liquidityManager;
    }

    /**
     * @notice Whitelist users
     * @param users The users to whitelist
     */
    function whitelistAddresses(address[] calldata users) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            whitelisted[users[i]] = true;
        }
    }

    /**
     * @notice Finalize the presale
     */
    function deposit() external {
        require(!finalized, "Presale ended");
        require(whitelisted[msg.sender], "Not whitelisted");
        require(!hasParticipated[msg.sender], "Already participated");
        require(totalParticipants < maxUsers, "Max reached");

        require(usdt.transferFrom(msg.sender, address(this), allocationPerUser), "USDT transfer failed");

        uint256 tokenAmount = (allocationPerUser * 1e18) / tokenPrice;

        hasParticipated[msg.sender] = true;
        totalParticipants++;
        totalRaised += allocationPerUser;
        participants.push(msg.sender);

        emit Deposited(msg.sender, allocationPerUser, tokenAmount);

        // Vesting will be set on finalize or batch call
    }

    /**
     * @notice Finalize the presale
     * @param liquidityUSDT The amount of USDT to send to the liquidity manager
     * @param liquidityTokens The amount of tokens to send to the liquidity manager
     * @dev Only the owner can finalize the presale
     */
    function finalizePresale(uint256 liquidityUSDT, uint256 liquidityTokens) external onlyOwner {
        require(!finalized, "Already finalized");
        require(totalRaised >= minCap, "Cap not met, enable refunds");

        usdt.approve(liquidityManager, liquidityUSDT);
        token.approve(liquidityManager, liquidityTokens);

        ILiquidityManager(liquidityManager).addLiquidityToUniswap(address(token), liquidityTokens, liquidityUSDT);

        finalized = true;

        // Set vesting for all participants
        address[] memory users = new address[](participants.length);
        uint256[] memory amounts = new uint256[](participants.length);

        for (uint256 i = 0; i < participants.length; i++) {
            users[i] = participants[i];
            amounts[i] = (allocationPerUser * 1e18) / tokenPrice;
        }

        IVestingVault(vault).batchSetVesting(users, amounts, 30 days, 300 days);

        emit Finalized(liquidityUSDT, liquidityTokens);
    }

    /**
     * @notice Enable refunds for the presale
     * @dev Only the owner can enable refunds
     */
    function enableRefunds() external onlyOwner {
        require(!finalized, "Already finalized");
        require(totalRaised < minCap, "Cap met");
        refundsEnabled = true;
    }

    /**
     * @notice Claim a refund for the presale
     * @dev Users can claim a refund
     */
    function claimRefund() external {
        require(refundsEnabled, "Refunds disabled");
        require(hasParticipated[msg.sender], "No deposit");
        require(!refunded[msg.sender], "Already refunded");

        refunded[msg.sender] = true;
        usdt.transfer(msg.sender, allocationPerUser);
        emit Refunded(msg.sender, allocationPerUser);
    }
}
