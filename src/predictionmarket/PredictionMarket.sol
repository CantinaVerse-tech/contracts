// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ExpandedERC20, ExpandedIERC20 } from "@uma/core/contracts/common/implementation/ExpandedERC20.sol";
import {
    OracleInterfaces,
    OptimisticOracleConstraints
} from "@uma/core/contracts/data-verification-mechanism/implementation/Constants.sol";
import { AddressWhitelist } from "@uma/core/contracts/common/implementation/AddressWhitelist.sol";
import { FinderInterface } from "@uma/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import { ClaimData } from "@uma/core/contracts/optimistic-oracle-v3/implementation/ClaimData.sol";
import { OptimisticOracleV3Interface } from
    "@uma/core/contracts/optimistic-oracle-v3/interfaces/OptimisticOracleV3Interface.sol";
import { OptimisticOracleV3CallbackRecipientInterface } from
    "@uma/core/contracts/optimistic-oracle-v3/interfaces/OptimisticOracleV3CallbackRecipientInterface.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IAMMContract } from "./interfaces/IAMMContract.sol";
import { PMLibrary } from "./lib/PMLibrary.sol";
import { PredictionMarketManager } from "./PredictionMarketManager.sol";

/**
 * @title PredictionMarket
 * @author CantinaVerse
 * @notice This contract allows users to create and participate in prediction markets using outcome tokens.
 * @dev The contract integrates with Uniswap V3 for liquidity provision and UMA's Optimistic Oracle V3 for dispute
 * resolution.
 */
contract PredictionMarket is OptimisticOracleV3CallbackRecipientInterface, Ownable, PredictionMarketManager {
    // Libraries
    using SafeERC20 for IERC20;
    using PMLibrary for PMLibrary.Market;

    // Immutable state variables
    FinderInterface public immutable finder; // UMA Finder contract to locate other UMA contracts.
    OptimisticOracleV3Interface public immutable optimisticOracle; // UMA Optimistic Oracle V3 for dispute resolution.
    IAMMContract public immutable amm; // Uniswap V3 AMM contract for liquidity provision.
    IERC20 public immutable currency; // Currency token used for rewards and bonds.
    bytes32 public immutable defaultIdentifier; // Default identifier for UMA Optimistic Oracle assertions.

    // Constants
    uint256 public constant MAX_FEE = 10_000; // 100% in basis points.

    // Storage
    mapping(bytes32 => PMLibrary.Market) private markets; // Maps marketId to Market struct.
    mapping(bytes32 => PMLibrary.AssertedMarket) private assertedMarkets; // Maps assertionId to AssertedMarket.
}
