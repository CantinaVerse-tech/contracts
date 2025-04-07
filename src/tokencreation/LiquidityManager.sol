// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { IUniswapV2Router02 } from "./interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Factory } from "./interfaces/IUniswapV2Factory.sol";

contract LiquidityManager is Ownable {
    // @notice Uniswap Router address
    IUniswapV2Router02 public immutable uniswapRouter;

    // @notice USDT address
    address public immutable usdtAddress;

    //Events
    // @notice Emitted when liquidity is added
    event LiquidityAdded(address indexed token, address pair, uint256 tokenAmount, uint256 usdtAmount);

    /**
     * @notice This constructor takes in Uniswap Router address and USDT address
     * @param _uniswapRouter is the Uniswap Router address
     * @param _usdtAddress is the USDT address
     */
    constructor(address _uniswapRouter, address _usdtAddress) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        usdtAddress = _usdtAddress;
    }

    /**
     * @dev Adds liquidity to Uniswap pool for a custom token against USDT.
     * @param token Address of the ERC20 token
     * @param tokenAmount Amount of token to add
     * @param usdtAmount Amount of USDT to pair with
     */
    function addLiquidityToUniswap(address token, uint256 tokenAmount, uint256 usdtAmount) external onlyOwner {
        // Transfer token + USDT to this contract
        IERC20(token).transferFrom(msg.sender, address(this), tokenAmount);
        IERC20(usdtAddress).transferFrom(msg.sender, address(this), usdtAmount);

        // Approve tokens to router
        IERC20(token).approve(address(uniswapRouter), tokenAmount);
        IERC20(usdtAddress).approve(address(uniswapRouter), usdtAmount);

        // Create pair if it doesn't exist
        address pair = IUniswapV2Factory(uniswapRouter.factory()).getPair(token, usdtAddress);
        if (pair == address(0)) {
            pair = IUniswapV2Factory(uniswapRouter.factory()).createPair(token, usdtAddress);
        }

        // Add liquidity
        (uint256 amountToken, uint256 amountUSDT,) = uniswapRouter.addLiquidity(
            token,
            usdtAddress,
            tokenAmount,
            usdtAmount,
            0, // slippage can be handled more robustly
            0,
            msg.sender, // LP tokens go to the user
            block.timestamp + 300
        );

        emit LiquidityAdded(token, pair, amountToken, amountUSDT);
    }
}
