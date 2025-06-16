// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/**
 * @title TokenVesting
 * @author CantinaVerse-Tech
 * @notice This contract implements a simple token vesting mechanism. The owner can create a vesting schedule for a
 * beneficiary, and the beneficiary can release the vested tokens at any time.
 */
contract TokenVesting {
    struct VestingSchedule {
        uint256 totalAmount;
        uint256 startTime;
        uint256 duration;
        uint256 releasedAmount;
        bool revoked;
    }

    mapping(address => VestingSchedule) public vestingSchedules;
    mapping(address => uint256) public tokenBalances;
    address public owner;
    uint256 public totalSupply;

    /**
     * @notice Constructor for the TokenVesting contract
     * @dev Sets the owner and total supply
     */
    constructor() {
        owner = msg.sender;
        totalSupply = 1_000_000 * 10 ** 18; // 1M tokens
        tokenBalances[owner] = totalSupply;
    }

    /**
     *
     * @param _beneficiary the address of the beneficiary
     * @param _amount the amount of tokens to vest
     * @param _duration the duration of the vesting in seconds
     * @notice Create a vesting schedule for a beneficiary
     * @dev Only the owner can create a vesting schedule
     */
    function createVesting(address _beneficiary, uint256 _amount, uint256 _duration) external {
        require(msg.sender == owner, "Not owner");
        require(tokenBalances[owner] >= _amount, "Insufficient tokens");
        require(vestingSchedules[_beneficiary].totalAmount == 0, "Already has vesting");

        tokenBalances[owner] -= _amount;

        vestingSchedules[_beneficiary] = VestingSchedule({
            totalAmount: _amount,
            startTime: block.timestamp,
            duration: _duration,
            releasedAmount: 0,
            revoked: false
        });
    }

    /**
     * @notice Release vested tokens according to the vesting schedule.
     * @dev Only the beneficiary can call this function.
     */
    function releaseTokens() external {
        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        require(schedule.totalAmount > 0, "No vesting schedule");
        require(!schedule.revoked, "Vesting revoked");

        uint256 releasableAmount = calculateReleasableAmount(msg.sender);
        require(releasableAmount > 0, "No tokens to release");

        schedule.releasedAmount += releasableAmount;
        tokenBalances[msg.sender] += releasableAmount;
    }

    /**
     * @notice Calculate the amount of tokens that can be released for a beneficiary
     * @param _beneficiary the address of the beneficiary
     * @return the amount of tokens that can be released
     * @dev This function returns the amount of tokens that can be released for a beneficiary.
     */
    function calculateReleasableAmount(address _beneficiary) public view returns (uint256) {
        VestingSchedule memory schedule = vestingSchedules[_beneficiary];

        if (schedule.revoked || schedule.totalAmount == 0) {
            return 0;
        }

        uint256 timeElapsed = block.timestamp - schedule.startTime;
        if (timeElapsed >= schedule.duration) {
            return schedule.totalAmount - schedule.releasedAmount;
        }

        uint256 vestedAmount = (schedule.totalAmount * timeElapsed) / schedule.duration;
        return vestedAmount - schedule.releasedAmount;
    }

    /**
     * @notice Revoke the vesting schedule for a beneficiary
     * @param _beneficiary the address of the beneficiary
     * @dev Only the owner can revoke the vesting schedule
     */
    function revokeVesting(address _beneficiary) external {
        require(msg.sender == owner, "Not owner");
        VestingSchedule storage schedule = vestingSchedules[_beneficiary];
        require(!schedule.revoked, "Already revoked");

        uint256 releasableAmount = calculateReleasableAmount(_beneficiary);
        if (releasableAmount > 0) {
            schedule.releasedAmount += releasableAmount;
            tokenBalances[_beneficiary] += releasableAmount;
        }

        schedule.revoked = true;
        uint256 remainingAmount = schedule.totalAmount - schedule.releasedAmount;
        tokenBalances[owner] += remainingAmount;
    }
}
