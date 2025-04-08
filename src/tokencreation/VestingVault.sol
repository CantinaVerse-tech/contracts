// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingVault is Ownable {
    // @notice The vesting schedule for a user
    struct VestingSchedule {
        uint256 totalAmount; // Total tokens locked for the user
        uint256 claimedAmount; // How much they’ve already claimed
        uint256 startTime; // When vesting begins
        uint256 cliffTime; // When first claim is allowed
        uint256 duration; // Total vesting duration (e.g. 10 months)
    }

    // @notice The token being held in the vault
    IERC20 public immutable token;

    // @notice The vesting schedules for each user
    mapping(address => VestingSchedule) public schedules;

    // Events
    // @notice Emitted when a vesting schedule is created
    event VestingAllocated(address indexed beneficiary, uint256 totalAmount);

    // @notice Emitted when tokens are claimed
    event TokensClaimed(address indexed beneficiary, uint256 amountClaimed);

    /**
     * @notice Constructor to set the token address
     * @param _token The token being held in the vault
     */
    constructor(address _token) {
        token = IERC20(_token);
    }

    /**
     * @notice Sets a vesting schedule for a user.
     * Can only be called by the owner (factory, launch contract, etc).
     */
    function setVesting(
        address beneficiary,
        uint256 totalAmount,
        uint256 cliffDuration, // in seconds
        uint256 vestingDuration // in seconds (e.g., 10 months = 10 * 30 * 24 * 60 * 60)
    )
        external
        onlyOwner
    {
        require(schedules[beneficiary].totalAmount == 0, "Already vested");
        require(totalAmount > 0, "No amount");

        uint256 start = block.timestamp;
        schedules[beneficiary] = VestingSchedule({
            totalAmount: totalAmount,
            claimedAmount: 0,
            startTime: start,
            cliffTime: start + cliffDuration,
            duration: vestingDuration
        });

        emit VestingAllocated(beneficiary, totalAmount);
    }

    /**
     * @notice Claim vested tokens according to the vesting schedule.
     */
    function claim() external {
        VestingSchedule storage vesting = schedules[msg.sender];
        require(vesting.totalAmount > 0, "No vesting");
        require(block.timestamp >= vesting.cliffTime, "Cliff not reached");

        uint256 vested = _vestedAmount(vesting);
        uint256 claimable = vested - vesting.claimedAmount;
        require(claimable > 0, "Nothing to claim");

        vesting.claimedAmount += claimable;
        token.transfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }
}
