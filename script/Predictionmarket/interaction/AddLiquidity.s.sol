// // SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../../HelperConfig.s.sol";
import { PredictionMarket } from "../../../src/predictionmarket/PredictionMarket.sol";
import { AMMContract } from "../../../src/predictionmarket/AMMContract.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract AddLiquidityScript is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;
        config = helperConfig.getBaseSepoliaConfig();

        vm.startBroadcast();
        AMMContract amm = AMMContract(0xC61Ba80Ab399e6F199aA4f5c0302eF7e0C66B7F8);
        PredictionMarket predictionMarket = PredictionMarket(0x722fAffe25b373106f75aa1Ac5BCa5B81dC6df38);

        IERC20 currency = IERC20(config.usdc);
        currency.approve(address(predictionMarket), 1e6);
        (, int24 tick,,,,,) = IUniswapV3Pool(0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2).slot0();
        uint256 tokenId = predictionMarket.createOutcomeTokensLiquidity(
            0x4d3b7461ff3a537673f332bbdf2775907850d4e7ed4bfcf9fe7860cea0b534da, 1e6, -120, 120
        );

        console2.log("Tick", tick);
        console2.log("TokenId", tokenId);
        vm.stopBroadcast();
    }
}
