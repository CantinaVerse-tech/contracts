// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

interface ILiquidityManager {
    function addLiquidityToUniswap(address token, uint256 tokenAmount, uint256 usdtAmount) external;
}
