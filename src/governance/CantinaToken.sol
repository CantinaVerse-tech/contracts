// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CantinaToken
 * @author CantinaVerse-Tech
 * @notice Governance token for the CantinaVerse ecosystem with voting capabilities
 * @dev Extends ERC20 with voting extensions to support governance
 */
contract CantinaToken is ERC20, ERC20Permit, ERC20Votes, Ownable {
    // Maximum supply cap
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10 ** 18; // 100 million tokens

    // Allocation percentages (in basis points, 100 = 1%)
    uint256 public constant COMMUNITY_ALLOCATION = 5000; // 50%
    uint256 public constant TEAM_ALLOCATION = 2000; // 20%
    uint256 public constant ECOSYSTEM_FUND = 1500; // 15%
    uint256 public constant TREASURY = 1500; // 15%

    // Vesting period for team tokens (6 months)
    uint256 public constant VESTING_PERIOD = 180 days;

    // Team vesting data
    address public teamVault;
    uint256 public vestingStart;
    uint256 public teamTokensReleased;
    uint256 public teamAllocation;

    // Treasury and ecosystem addresses
    address public treasuryAddress;
    address public ecosystemFundAddress;

    // Events
    event TeamVestingInitialized(address indexed teamVault, uint256 amount, uint256 vestingStart);
    event TeamTokensReleased(uint256 amount, uint256 timestamp);

    /**
     * @notice Constructor to initialize the contract
     * @param initialOwner The address that will initially own the token contract.
     * @param _teamVault The address of the team vault contract
     * @param _treasuryAddress The address of the treasury
     * @param _ecosystemFundAddress The address of the ecosystem fund
     */
    constructor(
        address initialOwner,
        address _teamVault,
        address _treasuryAddress,
        address _ecosystemFundAddress
    )
        ERC20("CantinaVerse Token", "CANTINA")
        ERC20Permit("CantinaVerse Token")
        Ownable(initialOwner)
    {
        // Set addresses
        teamVault = _teamVault;
        treasuryAddress = _treasuryAddress;
        ecosystemFundAddress = _ecosystemFundAddress;

        // Calculate token allocations
        uint256 communityTokens = (MAX_SUPPLY * COMMUNITY_ALLOCATION) / 10_000;
        teamAllocation = (MAX_SUPPLY * TEAM_ALLOCATION) / 10_000;
        uint256 ecosystemTokens = (MAX_SUPPLY * ECOSYSTEM_FUND) / 10_000;
        uint256 treasuryTokens = (MAX_SUPPLY * TREASURY) / 10_000;

        // Mint tokens according to allocations
        _mint(address(this), communityTokens); // Community allocation held by contract for distribution
        _mint(ecosystemFundAddress, ecosystemTokens); // Ecosystem fund allocation
        _mint(treasuryAddress, treasuryTokens); // Treasury allocation

        // Initialize team vesting
        _mint(address(this), teamAllocation); // Team allocation held by contract for vesting
        vestingStart = block.timestamp;
        teamTokensReleased = 0;

        emit TeamVestingInitialized(teamVault, teamAllocation, vestingStart);
    }

    /**
     * @notice Distributes tokens from the community allocation
     * @param recipients Array of recipient addresses
     * @param amounts Array of token amounts to distribute
     * @dev Only callable by owner
     */
    function distributeToLaunchpad(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Arrays must be same length");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(balanceOf(address(this)) >= totalAmount, "Insufficient community tokens");

        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(address(this), recipients[i], amounts[i]);
        }
    }

    /**
     * @notice Releases vested team tokens according to the vesting schedule
     * @dev Callable by anyone, but tokens always go to the teamVault
     */
    function releaseTeamTokens() external {
        uint256 vestedAmount = calculateVestedAmount();
        uint256 releasableAmount = vestedAmount - teamTokensReleased;

        require(releasableAmount > 0, "No tokens to release");

        teamTokensReleased += releasableAmount;
        _transfer(address(this), teamVault, releasableAmount);

        emit TeamTokensReleased(releasableAmount, block.timestamp);
    }

    /**
     * @notice Calculates the amount of team tokens that have vested
     * @return The vested token amount
     */
    function calculateVestedAmount() public view returns (uint256) {
        if (block.timestamp < vestingStart) {
            return 0;
        } else if (block.timestamp >= vestingStart + VESTING_PERIOD) {
            return teamAllocation;
        } else {
            return (teamAllocation * (block.timestamp - vestingStart)) / VESTING_PERIOD;
        }
    }

    /**
     * @notice Updates the treasury address
     * @param newTreasuryAddress The new treasury address
     * @dev Only callable by owner
     */
    function setTreasuryAddress(address newTreasuryAddress) external onlyOwner {
        require(newTreasuryAddress != address(0), "Zero address not allowed");
        treasuryAddress = newTreasuryAddress;
    }
}
