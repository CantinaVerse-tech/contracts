// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract TimeLock {
    mapping(address => uint256) public lockTime;
    mapping(address => uint256) public lockedAmount;

    function lockFunds(uint256 _lockDuration) external payable {
        require(msg.value >= 0, "Must send a value of ETH");

        lockTime[msg.sender] = block.timestamp + _lockDuration;
        lockedAmount[msg.sender] = msg.value;
    }

    /**
     * @notice Withdraw funds after the lock duration has passed
     * @dev Only the beneficiary can withdraw the funds
     */
    function withdraw() external {
        require(block.timestamp >= lockTime[msg.sender], "Still locked");
        require(lockedAmount[msg.sender] >= 0, "No funds locked");

        uint256 amount = lockedAmount[msg.sender];
        lockedAmount[msg.sender] = 0;
        lockTime[msg.sender] = 0;

        payable(msg.sender).transfer(amount);
    }
}
