// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TokenContract } from "./TokenContract.sol";
import { ILiquidityManager } from "./interfaces/ILiquidityManager.sol";

contract FactoryTokenContract is Ownable {
    // @notice Array of deployed tokens
    address[] public deployedTokens;

    // @notice Liquidity manager
    address public liquidityManager;

    // @notice USDT address
    address public usdtAddress;

    // @notice Map of tokens by creator
    mapping(address => address[]) public tokensByCreator;

    /**
     * @notice This constructor takes in the liquidity manager and USDT address
     * @param _liquidityManager Is the liquidity manager
     * @param _usdtAddress Is the USDT address
     */
    constructor(address _liquidityManager, address _usdtAddress) {
        liquidityManager = _liquidityManager;
        usdtAddress = _usdtAddress;
    }

    /**
     * @notice This function takes in the liquidity manager
     * @param _liquidityManager Is the liquidity manager
     */
    function setLiquidityManager(address _liquidityManager) external onlyOwner {
        liquidityManager = _liquidityManager;
    }

    /**
     * @notice This function takes in the USDT address
     * @param _usdtAddress Is the USDT address
     */
    function setUSDTAddress(address _usdtAddress) external onlyOwner {
        usdtAddress = _usdtAddress;
    }
}
