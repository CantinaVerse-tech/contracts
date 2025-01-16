// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ExpandedERC20, ExpandedIERC20 } from "@uma/core/contracts/common/implementation/ExpandedERC20.sol";
import {
    OracleInterfaces,
    OptimisticOracleConstraints
} from "@uma/core/contracts/data-verification-mechanism/implementation/Constants.sol";
import { AddressWhitelist } from "@uma/core/contracts/common/implementation/AddressWhitelist.sol";
import { FinderInterface } from "@uma/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import { OptimisticOracleV3Interface } from
    "@uma/core/contracts/optimistic-oracle-v3/interfaces/OptimisticOracleV3Interface.sol";
import { OptimisticOracleV3CallbackRecipientInterface } from
    "@uma/core/contracts/optimistic-oracle-v3/interfaces/OptimisticOracleV3CallbackRecipientInterface.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AMMContract } from "./AMMContract.sol";
import { PredictionMarketLib } from "../lib/PredictionMarketLib.sol";

contract PredictionMarket is OptimisticOracleV3CallbackRecipientInterface, Ownable {
    error PredictionMarket__UnsupportedCurrency();
    error PredictionMarket__MarketDoesNotExist();
    error PredictionMarket__AssertionActiveOrResolved();
    error PredictionMarket__NotAuthorized();
    error PredictionMarket__MarketNotResolved();

    using SafeERC20 for IERC20;
    using PredictionMarketLib for PredictionMarketLib.Market;

    FinderInterface public immutable finder; // UMA protocol Finder used to discover other protocol contracts.
    OptimisticOracleV3Interface public immutable optimisticOracle;
    AMMContract public immutable amm; // Uniswap V4 AMM contract used to manage trading of outcome tokens.
    AddressWhitelist public immutable collateralWhitelist;
    IERC20 private immutable currency; // Currency used for all prediction markets.
    uint64 private constant ASSERTION_LIVENESS = 7200; // 2 hours.
    bytes32 private immutable defaultIdentifier; // Identifier used for all prediction markets.
    bytes private constant UNRESOLVABLE = "Unresolvable"; // Name of the unresolvable outcome where payouts are split.

    mapping(bytes32 => PredictionMarketLib.Market) private markets; // Maps marketId to Market struct.
    mapping(bytes32 => PredictionMarketLib.AssertedMarket) private assertedMarkets; // Maps assertionId to
        // AssertedMarket.

    event MarketInitialized(
        bytes32 indexed marketId,
        string indexed outcome1,
        string indexed outcome2,
        string description,
        address outcome1Token,
        address outcome2Token,
        uint256 reward,
        uint256 requiredBond,
        uint24 poolFee
    );
    event MarketAsserted(bytes32 indexed marketId, string indexed assertedOutcome, bytes32 indexed assertionId);
    event MarketResolved(bytes32 indexed marketId);
    event TokensCreated(bytes32 indexed marketId, address indexed account, uint256 indexed tokensCreated);
    event TokensRedeemed(bytes32 indexed marketId, address indexed account, uint256 indexed tokensRedeemed);
    event TokensSettled(
        bytes32 indexed marketId,
        address indexed account,
        uint256 indexed payout,
        uint256 outcome1Tokens,
        uint256 outcome2Tokens
    );

    constructor(address _finder, address _currency, address _optimisticOracleV3, address _ammContract) {
        finder = FinderInterface(_finder);
        if (!_getCollateralWhitelist().isOnWhitelist(_currency)) {
            revert PredictionMarket__UnsupportedCurrency();
        }
        currency = IERC20(_currency);
        optimisticOracle = OptimisticOracleV3Interface(_optimisticOracleV3);
        defaultIdentifier = optimisticOracle.defaultIdentifier();
        amm = AMMContract(_ammContract);
    }

    function initializeMarket(
        string memory outcome1, // Short name of the first outcome.
        string memory outcome2, // Short name of the second outcome.
        string memory description, // Description of the market.
        uint256 reward, // Reward available for asserting true market outcome.
        uint256 requiredBond, // Expected bond to assert market outcome (optimisticOraclev3 can require higher bond).
        uint24 poolFee // Uniswap pool fee
    )
        external
        returns (bytes32 marketId)
    {
        marketId = keccak256(abi.encode(block.number, description));

        PredictionMarketLib.validateMarketParameters(outcome1, outcome2, description, markets[marketId]);

        // Create position tokens with this contract having minter and burner roles.
        ExpandedIERC20 outcome1Token = new ExpandedERC20(string(abi.encodePacked(outcome1, " Token")), "O1T", 18);
        ExpandedIERC20 outcome2Token = new ExpandedERC20(string(abi.encodePacked(outcome2, " Token")), "O2T", 18);
        outcome1Token.addMinter(address(this));
        outcome2Token.addMinter(address(this));
        outcome1Token.addBurner(address(this));
        outcome2Token.addBurner(address(this));

        markets[marketId] = PredictionMarketLib.Market({
            resolved: false,
            assertedOutcomeId: bytes32(0),
            outcome1Token: outcome1Token,
            outcome2Token: outcome2Token,
            reward: reward,
            requiredBond: requiredBond,
            outcome1: bytes(outcome1),
            outcome2: bytes(outcome2),
            description: bytes(description),
            fee: poolFee
        });
        if (reward > 0) {
            currency.safeTransferFrom(msg.sender, address(this), reward);
        } // Pull reward.

        // Initialize Uniswap V3 pool
        //amm.initializePool(address(outcome1Token), address(outcome2Token), poolFee, marketId);

        emit MarketInitialized(
            marketId,
            outcome1,
            outcome2,
            description,
            address(outcome1Token),
            address(outcome2Token),
            reward,
            requiredBond,
            poolFee
        );
    }

    // Assert the market with any of 3 possible outcomes: names of outcome1, outcome2 or unresolvable.
    // Only one concurrent assertion per market is allowed.
    function assertMarket(bytes32 marketId, string memory assertedOutcome) external returns (bytes32 assertionId) {
        PredictionMarketLib.Market storage market = markets[marketId];
        if (market.outcome1Token == ExpandedIERC20(address(0))) {
            revert PredictionMarket__MarketDoesNotExist();
        }
        bytes32 assertedOutcomeId = keccak256(bytes(assertedOutcome));
        require(
            PredictionMarketLib.validateAssertedOutcome(
                assertedOutcomeId, market.outcome1, market.outcome2, UNRESOLVABLE
            ),
            "Invalid assertion outcome"
        );

        market.assertedOutcomeId = assertedOutcomeId;
        uint256 minimumBond = optimisticOracle.getMinimumBond(address(currency)); // optimisticOraclev3 might require
            // higher bond.
        uint256 bond = market.requiredBond > minimumBond ? market.requiredBond : minimumBond;

        // Pull bond and make the assertion.
        currency.safeTransferFrom(msg.sender, address(this), bond);
        currency.forceApprove(address(optimisticOracle), bond);

        bytes memory claim = PredictionMarketLib.composeClaim(assertedOutcome, market.description, block.timestamp);
        assertionId = _assertTruthWithDefaults(claim, bond);

        // Store the asserter and marketId for the assertionResolvedCallback.
        assertedMarkets[assertionId] = PredictionMarketLib.AssertedMarket({ asserter: msg.sender, marketId: marketId });

        emit MarketAsserted(marketId, assertedOutcome, assertionId);
    }

    // Callback from settled assertion.
    // If the assertion was resolved true, then the asserter gets the reward and the market is marked as resolved.
    // Otherwise, assertedOutcomeId is reset and the market can be asserted again.
    function assertionResolvedCallback(bytes32 assertionId, bool assertedTruthfully) external {
        if (msg.sender != address(optimisticOracle)) {
            revert PredictionMarket__NotAuthorized();
        }
        PredictionMarketLib.Market storage market = markets[assertedMarkets[assertionId].marketId];

        if (assertedTruthfully) {
            market.resolved = true;
            if (market.reward > 0) {
                currency.safeTransfer(assertedMarkets[assertionId].asserter, market.reward);
            }
            emit MarketResolved(assertedMarkets[assertionId].marketId);
        } else {
            market.assertedOutcomeId = bytes32(0);
        }
        delete assertedMarkets[assertionId];
    }

    // Dispute callback does nothing.
    function assertionDisputedCallback(bytes32 assertionId) external { }

    // Mints pair of tokens representing the value of outcome1 and outcome2. Trading of outcome tokens is outside of the
    // scope of this contract. The caller must approve this contract to spend the currency tokens.
    // TO-DO: We need Uniswap Trading Pairs!
    function createOutcomeTokens(bytes32 marketId, uint256 tokensToCreate) external {
        PredictionMarketLib.Market storage market = markets[marketId];
        if (market.outcome1Token == ExpandedIERC20(address(0))) {
            revert PredictionMarket__MarketDoesNotExist();
        }
        PredictionMarketLib.createOutcomeTokens(market, msg.sender, tokensToCreate, currency);
        emit TokensCreated(marketId, msg.sender, tokensToCreate);
    }

    // Burns equal amount of outcome1 and outcome2 tokens returning settlement currency tokens.
    function redeemOutcomeTokens(bytes32 marketId, uint256 tokensToRedeem) external {
        PredictionMarketLib.Market storage market = markets[marketId];
        if (market.outcome1Token == ExpandedIERC20(address(0))) {
            revert PredictionMarket__MarketDoesNotExist();
        }
        PredictionMarketLib.redeemOutcomeTokens(market, msg.sender, tokensToRedeem, currency);
        emit TokensRedeemed(marketId, msg.sender, tokensToRedeem);
    }

    // If the market is resolved, then all of caller's outcome tokens are burned and currency payout is made depending
    // on the resolved market outcome and the amount of outcome tokens burned. If the market was resolved to the first
    // outcome, then the payout equals balance of outcome1Token while outcome2Token provides nothing. If the market was
    // resolved to the second outcome, then the payout equals balance of outcome2Token while outcome1Token provides
    // nothing. If the market was resolved to the split outcome, then both outcome tokens provides half of their balance
    // as currency payout.
    function settleOutcomeTokens(bytes32 marketId) external returns (uint256 payout) {
        PredictionMarketLib.Market storage market = markets[marketId];
        if (!market.resolved) {
            revert PredictionMarket__MarketNotResolved();
        }
        uint256 outcome1Balance = market.outcome1Token.balanceOf(msg.sender);
        uint256 outcome2Balance = market.outcome2Token.balanceOf(msg.sender);

        payout = PredictionMarketLib.calculatePayout(market, outcome1Balance, outcome2Balance);

        market.outcome1Token.burnFrom(msg.sender, outcome1Balance);
        market.outcome2Token.burnFrom(msg.sender, outcome2Balance);
        currency.safeTransfer(msg.sender, payout);

        emit TokensSettled(marketId, msg.sender, payout, outcome1Balance, outcome2Balance);
    }

    function _assertTruthWithDefaults(bytes memory claim, uint256 bond) internal returns (bytes32 assertionId) {
        assertionId = optimisticOracle.assertTruth(
            claim,
            msg.sender, // Asserter
            address(this), // Receive callback in this contract.
            address(0), // No sovereign security.
            ASSERTION_LIVENESS,
            currency,
            bond,
            defaultIdentifier,
            bytes32(0) // No domain.
        );
    }

    function _getCollateralWhitelist() internal view returns (AddressWhitelist) {
        return AddressWhitelist(finder.getImplementationAddress(OracleInterfaces.CollateralWhitelist));
    }

    function getMarket(bytes32 marketId)
        external
        view
        returns (
            bool resolved,
            bytes32 assertedOutcomeId,
            address outcome1Token,
            address outcome2Token,
            uint256 reward,
            uint256 requiredBond,
            string memory outcome1,
            string memory outcome2,
            string memory description,
            uint24 fee
        )
    {
        PredictionMarketLib.Market storage market = markets[marketId];
        require(address(market.outcome1Token) != address(0), "Market does not exist");

        (address token1, address token2) = PredictionMarketLib.getMarketTokenAddresses(market);
        (string memory out1, string memory out2) = PredictionMarketLib.getMarketOutcomes(market);
        (bool res, bytes32 assertId) = PredictionMarketLib.getMarketStatus(market);

        return (
            res,
            assertId,
            token1,
            token2,
            market.reward,
            market.requiredBond,
            out1,
            out2,
            string(market.description),
            market.fee
        );
    }

    function getMarketTokens(bytes32 marketId) external view returns (address outcome1Token, address outcome2Token) {
        PredictionMarketLib.Market storage market = markets[marketId];
        require(address(market.outcome1Token) != address(0), "Market does not exist");
        return PredictionMarketLib.getMarketTokenAddresses(market);
    }

    function getMarketOutcomes(bytes32 marketId)
        external
        view
        returns (string memory outcome1, string memory outcome2)
    {
        PredictionMarketLib.Market storage market = markets[marketId];
        require(address(market.outcome1Token) != address(0), "Market does not exist");
        return PredictionMarketLib.getMarketOutcomes(market);
    }

    function getMarketStatus(bytes32 marketId) external view returns (bool resolved, bytes32 assertedOutcomeId) {
        PredictionMarketLib.Market storage market = markets[marketId];
        require(address(market.outcome1Token) != address(0), "Market does not exist");
        return PredictionMarketLib.getMarketStatus(market);
    }

    function getAssertedMarket(bytes32 assertionId) external view returns (address asserter, bytes32 marketId) {
        PredictionMarketLib.AssertedMarket memory assertedMarket = assertedMarkets[assertionId];
        return (assertedMarket.asserter, assertedMarket.marketId);
    }

    function getCurrency() external view returns (address) {
        return address(currency);
    }

    function getAssertionLiveness() external pure returns (uint64) {
        return ASSERTION_LIVENESS;
    }

    function getDefaultIdentifier() external view returns (bytes32) {
        return defaultIdentifier;
    }

    function getUnresolvableOutcome() external pure returns (string memory) {
        return string(UNRESOLVABLE);
    }

    function getOutcomeTokenBalances(bytes32 marketId, address account) external view returns (uint256, uint256) {
        PredictionMarketLib.Market storage market = markets[marketId];
        require(address(market.outcome1Token) != address(0), "Market does not exist");

        return (market.outcome1Token.balanceOf(account), market.outcome2Token.balanceOf(account));
    }
}
