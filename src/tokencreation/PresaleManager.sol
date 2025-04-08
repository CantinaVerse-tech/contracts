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
}
