// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { PMLibrary } from "./lib/PMLibrary.sol";

/**
 * @title PredictionMarketManager
 * @author CantinaVerse
 * @notice This contract is responsible for managing prediction markets.
 * @dev The contract allows whitelisted addresses to create prediction markets.
 */
contract PredictionMarketManager is Ownable {
    // Custom errors
    error MarketFactory__CallerNotWhitelisted();

    // Whitelist state
    mapping(address => bool) public whitelistedAddresses;

    /**
     * @notice Constructor to initialize the factory contract
     */
    constructor() { }

    /**
     * @notice Modifier to restrict access to whitelisted addresses.
     * @dev Reverts if the caller is not in the whitelist.
     */
    modifier onlyWhitelisted() {
        if (!whitelistedAddresses[msg.sender]) {
            revert MarketFactory__CallerNotWhitelisted();
        }
        _;
    }
}
