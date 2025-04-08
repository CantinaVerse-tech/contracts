// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingVault is Ownable {
    struct VestingSchedule {
        uint256 totalAmount; // Total tokens locked for the user
        uint256 claimedAmount; // How much they’ve already claimed
        uint256 startTime; // When vesting begins
        uint256 cliffTime; // When first claim is allowed
        uint256 duration; // Total vesting duration (e.g. 10 months)
    }

    IERC20 public immutable token;
    mapping(address => VestingSchedule) public schedules;
}
