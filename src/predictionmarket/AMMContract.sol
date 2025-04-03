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

    /**
     * @notice Abstract function to create, initialize and update pool data in this contract.
     * @param _tokenA Address of the first token.
     * @param _tokenB Address of the second token.
     * @param _fee Fee tier for the pool.
     * @param _marketId Unique identifier for the prediction market.
     */
    function initializePool(
        address _tokenA,
        address _tokenB,
        uint24 _fee,
        bytes32 _marketId
    )
        external
        returns (address poolAddress)
    {
        /// @dev Create the pool
        poolAddress = _createPool(_marketId, _tokenA, _tokenB, _fee);

        /// @dev Initialize pool and update pool data in this contract
        _initializePoolAndUpdateContract(
            PoolData({
                marketId: _marketId,
                pool: poolAddress,
                tokenA: _tokenA,
                tokenB: _tokenB,
                fee: _fee,
                poolInitialized: false
            })
        );
    }

    /**
     * @notice Abstract function to add liquidity to a pool.
     * @param _marketId Unique identifier for the prediction market.
     * @param _user Address of the user.
     * @param _amount0 Amount of tokenA to add.
     * @param _amount1 Amount of tokenB to add.
     * @param _tickLower Lower tick bound for the liquidity position.
     * @param _tickUpper Upper tick bound for the liquidity position.
     * @return tokenId The token ID of the position.
     * @return liquidity The liquidity of the position.
     * @return amount0 The amount of tokenA in the position.
     * @return amount1 The amount of tokenB in the position.
     */
    function addLiquidity(
        bytes32 _marketId,
        address _user,
        uint256 _amount0,
        uint256 _amount1,
        int24 _tickLower,
        int24 _tickUpper
    )
        external
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        PoolData storage poolData = marketIdToPool[_marketId];
        require(poolData.poolInitialized, "Pool not active");

        /// @dev Transfer tokens from the sender to this contract
        IERC20(poolData.tokenA).transferFrom(msg.sender, address(this), _amount0);
        IERC20(poolData.tokenB).transferFrom(msg.sender, address(this), _amount1);

        /// @dev Mint a new position if the user doesn't have a position.
        if (userAddressToMarketIdToPositionId[_user][_marketId] == 0) {
            (tokenId,,,) =
                _mintNewPosition(marketIdToPool[_marketId], _user, _amount0, _amount1, _tickLower, _tickUpper);
        }
        /// @dev Else add liquidity to the existing position.
        else if (userAddressToMarketIdToPositionId[_user][_marketId] != 0) {
            _addLiquidityToExistingPosition(marketIdToPool[_marketId], _user, _amount0, _amount1);
            tokenId = userAddressToMarketIdToPositionId[_user][_marketId];
        }

        /// @dev Refund the user if there is a difference between liquidity added actually and liquidity added in the
        /// params.
        _refundExtraLiquidityWhileMinting(marketIdToPool[_marketId], amount0, amount1, _amount0, _amount1);

        /// @dev Call getter and return current user holdings.
        (,,,, liquidity,,,,, amount0, amount1) = getUserPositionInPool(_user, _marketId);

        emit LiquidityAdded(_marketId, amount0, amount1);
    }

    /**
     * @notice Abstract Function to remove liquidity and collect tokens from an existing position.
     * @param _marketId Unique identifier for the prediction market.
     * @param _user Address of the user.
     * @param _liquidity Liquidity to decrease.
     * @param _amount0Min Minimum amount of tokenA to receive.
     * @param _amount1Min Minimum amount of tokenB to receive.
     * @return amount0Decreased Amount of tokenA decreased.
     * @return amount1Decreased Amount of tokenB decreased.
     * @return amount0Collected Amount of tokenA collected.
     * @return amount1Collected Amount of tokenB collected.
     */
    function removeLiquidity(
        bytes32 _marketId,
        address _user,
        uint128 _liquidity,
        uint256 _amount0Min,
        uint256 _amount1Min
    )
        external
        returns (uint256 amount0Decreased, uint256 amount1Decreased, uint256 amount0Collected, uint256 amount1Collected)
    {
        (amount0Decreased, amount1Decreased) =
            _decreaseLiquidity(marketIdToPool[_marketId], _user, _liquidity, _amount0Min, _amount1Min);
        (amount0Collected, amount1Collected) = _collectTokensFromPosition(marketIdToPool[_marketId], _user);
    }
}
