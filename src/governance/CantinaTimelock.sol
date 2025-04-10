// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title CantinaTimelock
 * @author CantinaVerse-Tech
 * @notice Timelock controller for delayed execution of governance proposals
 * @dev Extends OpenZeppelin's TimelockController
 */
contract CantinaTimelock is TimelockController {
    /**
     * @notice Constructor for CantinaTimelock
     * @param minDelay The minimum delay before execution
     * @param proposers Array of addresses that can propose
     * @param executors Array of addresses that can execute
     * @param admin Admin address
     */
    constructor(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    )
        TimelockController(minDelay, proposers, executors, admin)
    { }
}
