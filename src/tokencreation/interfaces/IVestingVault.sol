// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface IVestingVault {
    function batchSetVesting(
        address[] calldata users,
        uint256[] calldata amounts,
        uint256 cliff,
        uint256 duration
    )
        external;
    function setVesting(address user, uint256 totalAmount, uint256 cliff, uint256 duration) external;
}
