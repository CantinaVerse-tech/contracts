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
    // Whitelist state
    mapping(address => bool) public whitelistedAddresses;

    /**
     * @notice Constructor to initialize the factory contract
     */
    constructor() { }
}
