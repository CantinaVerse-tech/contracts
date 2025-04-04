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
    // Custom errors
    error PredictionMarket__OutcomesAreTheSame();
    error PredictionMarket__MarketAlreadyExists();
    error PredictionMarket__MarketDoesNotExist();
    error PredictionMarket__InvalidAssertionOutcome();

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

    // Events
    event MarketInitialized(
        bytes32 indexed marketId,
        string outcome1,
        string outcome2,
        string description,
        address outcome1Token,
        address outcome2Token,
        uint256 reward,
        uint256 requiredBond,
        uint24 poolFee,
        string imageURL
    );
    event TokensCreated(bytes32 indexed marketId, address account, uint256 tokensCreated);
    event MarketAsserted(bytes32 indexed marketId, string assertedOutcome, bytes32 assertionId);

    /**
     * @notice Constructor to initialize the contract with required dependencies.
     * @param _finder Address of the UMA Finder contract.
     * @param _currency Address of the currency token used for rewards and bonds.
     * @param _optimisticOracleV3 Address of the UMA Optimistic Oracle V3 contract.
     * @param _ammContract Address of the Uniswap V3 AMM contract.
     */
    constructor(address _finder, address _currency, address _optimisticOracleV3, address _ammContract) {
        finder = FinderInterface(_finder);
        require(PMLibrary.getCollateralWhitelist(finder).isOnWhitelist(_currency), "Unsupported currency");
        currency = IERC20(_currency);
        optimisticOracle = OptimisticOracleV3Interface(_optimisticOracleV3);
        defaultIdentifier = optimisticOracle.defaultIdentifier();
        amm = IAMMContract(_ammContract);
    }

    /**
     * @notice Initializes a new prediction market.
     * @dev Creates outcome tokens and initializes a Uniswap V3 pool for the market.
     *      Only callable by whitelisted addresses.
     * @param outcome1 Short name of the first outcome.
     * @param outcome2 Short name of the second outcome.
     * @param description Description of the market.
     * @param reward Reward available for asserting the true market outcome.
     * @param requiredBond Expected bond to assert the market outcome.
     * @param poolFee Uniswap V3 pool fee tier.
     * @return marketId Unique identifier for the market.
     */
    function initializeMarket(
        string memory outcome1,
        string memory outcome2,
        string memory description,
        uint256 reward,
        uint256 requiredBond,
        uint24 poolFee,
        string memory imageURL
    )
        external
        onlyWhitelisted
        returns (bytes32 marketId)
    {
        if (keccak256(bytes(outcome1)) == keccak256(bytes(outcome2))) {
            revert PredictionMarket__OutcomesAreTheSame();
        }

        marketId = keccak256(abi.encode(block.number, description));
        if (markets[marketId].outcome1Token != ExpandedIERC20(address(0))) {
            revert PredictionMarket__MarketAlreadyExists();
        }

        // Create outcome tokens with this contract having minter and burner roles.
        (ExpandedIERC20 outcome1Token, ExpandedIERC20 outcome2Token) =
            PMLibrary.createTokensInsideInitializeMarketFunc(outcome1, outcome2);

        // Store market data
        markets[marketId] = PMLibrary.Market({
            resolved: false,
            assertedOutcomeId: bytes32(0),
            outcome1Token: outcome1Token,
            outcome2Token: outcome2Token,
            reward: reward,
            requiredBond: requiredBond,
            outcome1: bytes(outcome1),
            outcome2: bytes(outcome2),
            description: bytes(description),
            fee: poolFee,
            imageURL: bytes(imageURL)
        });

        // Transfer reward if provided
        if (reward > 0) {
            currency.safeTransferFrom(msg.sender, address(this), reward);
        }

        // Initialize Uniswap V3 pool
        amm.initializePool(address(outcome1Token), address(outcome2Token), poolFee, marketId);

        emit MarketInitialized(
            marketId,
            outcome1,
            outcome2,
            description,
            address(outcome1Token),
            address(outcome2Token),
            reward,
            requiredBond,
            poolFee,
            imageURL
        );
    }

    /**
     * @notice Creates outcome tokens and adds liquidity to the Uniswap V3 pool.
     * @dev The caller must approve this contract to spend the currency tokens.
     * @param marketId Unique identifier for the market.
     * @param tokensToCreate Amount of tokens to create.
     * @param tickLower Lower tick bound for the liquidity position.
     * @param tickUpper Upper tick bound for the liquidity position.
     */
    function createOutcomeTokensLiquidity(
        bytes32 marketId,
        uint256 tokensToCreate,
        int24 tickLower,
        int24 tickUpper
    )
        external
        returns (uint256 tokenId)
    {
        PMLibrary.Market storage market = markets[marketId];
        if (market.outcome1Token == ExpandedIERC20(address(0))) {
            revert PredictionMarket__MarketDoesNotExist();
        }

        // Create outcome tokens and mint them to this contract so that we can add liquidity to the Uniswap V3 pool.
        PMLibrary.createOutcomeTokensInsideCreateOutcomeTokensLiquidityFunc(
            market, msg.sender, tokensToCreate, currency
        );

        uint256 liquidityAmount = tokensToCreate / 2;

        // Approve AMM contract to spend the outcome tokens
        market.outcome1Token.approve(address(amm), liquidityAmount);
        market.outcome2Token.approve(address(amm), liquidityAmount);

        // Add liquidity to the Uniswap V3 pool and get the tokenId
        (tokenId,,,) = amm.addLiquidity(marketId, msg.sender, liquidityAmount, liquidityAmount, tickLower, tickUpper);

        emit TokensCreated(marketId, msg.sender, tokensToCreate);

        return tokenId;
    }

    /**
     * @notice Asserts the market outcome using UMA's Optimistic Oracle V3.
     * @dev Only one concurrent assertion per market is allowed.
     * @param marketId Unique identifier for the market.
     * @param assertedOutcome The outcome being asserted.
     * @return assertionId Unique identifier for the assertion.
     */
    function assertMarket(bytes32 marketId, string memory assertedOutcome) external returns (bytes32 assertionId) {
        PMLibrary.Market storage market = markets[marketId];
        if (market.outcome1Token == ExpandedIERC20(address(0))) {
            revert PredictionMarket__MarketDoesNotExist();
        }
        bytes32 assertedOutcomeId = keccak256(bytes(assertedOutcome));
        if (!PMLibrary.isValidOutcome(assertedOutcomeId, market.outcome1, market.outcome2)) {
            revert PredictionMarket__InvalidAssertionOutcome();
        }

        market.assertedOutcomeId = assertedOutcomeId;
        uint256 minimumBond = optimisticOracle.getMinimumBond(address(currency));
        uint256 bond = market.requiredBond > minimumBond ? market.requiredBond : minimumBond;

        // Transfer bond and make the assertion
        currency.safeTransferFrom(msg.sender, address(this), bond);
        currency.forceApprove(address(optimisticOracle), bond);

        bytes memory claim = PMLibrary.composeClaim(assertedOutcome, market.description, block.timestamp);

        // Use the library function to assert truth
        assertionId = PMLibrary.assertTruthWithDefaults(
            optimisticOracle, claim, msg.sender, address(this), currency, bond, defaultIdentifier
        );

        // Store the asserter and marketId for the callback
        assertedMarkets[assertionId] = PMLibrary.AssertedMarket({ asserter: msg.sender, marketId: marketId });

        emit MarketAsserted(marketId, assertedOutcome, assertionId);
    }
}
