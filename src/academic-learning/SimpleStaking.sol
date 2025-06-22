// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract SimpleStaking {
    struct Stake {
        uint256 amount;
        uint256 timestamp;
        uint256 rewardDebt;
    }

    mapping(address => Stake) public stakes;
    mapping(address => uint256) public tokenBalance;
    uint256 public totalStaked;
    uint256 public rewardRate = 100; // 1% per day (100 basis points)
    uint256 public constant SECONDS_PER_DAY = 86_400;
    address public owner;

    constructor() {
        owner = msg.sender;
        tokenBalance[owner] = 1_000_000 * 10 ** 18; // 1M tokens for rewards
    }

    /**
     * @notice Stake ETH to earn rewards.
     * @dev Users can stake ETH to earn rewards based on the amount staked and the duration of the stake.
     */
    function stake() external payable {
        require(msg.value > 0, "Must stake ETH");

        if (stakes[msg.sender].amount > 0) {
            claimRewards();
        }

        stakes[msg.sender].amount += msg.value;
        stakes[msg.sender].timestamp = block.timestamp;
        totalStaked += msg.value;
    }

    /**
     * @notice Unstake ETH.
     * @param _amount The amount of ETH to unstake
     * @dev Users can unstake ETH by specifying the amount they want to unstake.
     */
    function unstake(uint256 _amount) external {
        require(stakes[msg.sender].amount >= _amount, "Insufficient stake");

        claimRewards();

        stakes[msg.sender].amount -= _amount;
        totalStaked -= _amount;

        if (stakes[msg.sender].amount == 0) {
            delete stakes[msg.sender];
        }

        payable(msg.sender).transfer(_amount);
    }

    /**
     * @notice Claim rewards.
     * @dev Users can claim their rewards by calling this function.
     */
    function claimRewards() public {
        uint256 rewards = calculateRewards(msg.sender);
        if (rewards > 0) {
            stakes[msg.sender].timestamp = block.timestamp;
            tokenBalance[owner] -= rewards;
            tokenBalance[msg.sender] += rewards;
        }
    }

    /**
     * @notice Calculate rewards for a user.
     * @param _staker The address of the user to calculate rewards for
     * @return uint256 The total rewards for the user
     */
    function calculateRewards(address _staker) public view returns (uint256) {
        Stake memory userStake = stakes[_staker];
        if (userStake.amount == 0) return 0;

        uint256 stakingDuration = block.timestamp - userStake.timestamp;
        uint256 dailyReward = (userStake.amount * rewardRate) / 10_000;
        uint256 totalReward = (dailyReward * stakingDuration) / SECONDS_PER_DAY;

        return totalReward;
    }

    /**
     * @notice Set the reward rate.
     * @param _newRate The new reward rate in basis points
     * @dev Only the owner can set the reward rate.
     */
    function setRewardRate(uint256 _newRate) external {
        require(msg.sender == owner, "Not owner");
        require(_newRate <= 1000, "Max 10% daily");
        rewardRate = _newRate;
    }
}
