// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

    constructor() {
        owner = msg.sender;
        totalSupply = 1_000_000 * 10 ** 18; // 1M tokens
        tokenBalances[owner] = totalSupply;
    }

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

    function releaseTokens() external {
        VestingSchedule storage schedule = vestingSchedules[msg.sender];
        require(schedule.totalAmount > 0, "No vesting schedule");
        require(!schedule.revoked, "Vesting revoked");

        uint256 releasableAmount = calculateReleasableAmount(msg.sender);
        require(releasableAmount > 0, "No tokens to release");

        schedule.releasedAmount += releasableAmount;
        tokenBalances[msg.sender] += releasableAmount;
    }
}
