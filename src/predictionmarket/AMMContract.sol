// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import { IUniswapV3SwapCallback } from "@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import { ExpandedERC20, ExpandedIERC20 } from "@uma/core/contracts/common/implementation/ExpandedERC20.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { LiquidityAmounts } from "./lib/LiquidityAmounts.sol";
import { TickMath } from "./lib/TickMath.sol";
import { INonfungiblePositionManager } from "./interfaces/INonfungiblePositionManager.sol";

/**
 * @title AMMContract
 * @author CantinaVerse
 * @notice This contract manages the trading of outcome tokens from a prediction market using Uniswap V3 liquidity
 * pools.
 * @notice This contract also handles user's position in pools(i.e. tickets), the owner of position NFT is this contract
 * to manage liquidity position for the user, such as add and remove liquidity.
 * @dev The creation of pools is automated when a new market is initialized in the prediction market.
 */
contract AMMContract is Ownable {
    /// @notice Immutable Uniswap V3 factory and swap router addresses
    IUniswapV3Factory public immutable magicFactory;
    ISwapRouter public immutable swapRouter;
    INonfungiblePositionManager public immutable nonFungiblePositionManager;

    /// @notice Struct to store pool-related data
    struct PoolData {
        bytes32 marketId; // Unique identifier for the prediction market
        address pool; // Address of the Uniswap V3 pool
        address tokenA; // Address of the first token in the pool
        address tokenB; // Address of the second token in the pool
        uint24 fee; // Fee tier for the pool
        bool poolInitialized; // Flag to check if the pool is initialized
    }

    /// @notice Array to store all pools
    PoolData[] public pools;

    mapping(bytes32 => PoolData) public marketIdToPool;

    /// @dev Maps marketId to PoolData
    mapping(address => PoolData) public poolAddressToPool;
    /// @dev Maps pool address to PoolData
    mapping(address => mapping(address => address)) public tokenPairToPoolAddress;
    /// @dev Maps token pairs to pool addresses
    mapping(address => mapping(bytes32 => uint256)) public userAddressToMarketIdToPositionId;
    /// @dev Maps user address to their position token id in the respective market

    constructor(address _uniswapV3Factory, address _uniswapSwapRouter, address _uniswapNonFungiblePositionManager) {
        magicFactory = IUniswapV3Factory(_uniswapV3Factory);
        swapRouter = ISwapRouter(_uniswapSwapRouter);
        nonFungiblePositionManager = INonfungiblePositionManager(_uniswapNonFungiblePositionManager);
    }
}
