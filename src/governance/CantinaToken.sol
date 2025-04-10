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
}
