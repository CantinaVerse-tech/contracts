// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { PredictionMarket } from "../../src/predictionmarket/PredictionMarket.sol";

contract DeployPredictionMarket is Script {
    function run() external returns (PredictionMarket) {
        HelperConfig helpConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        config = helpConfig.getBaseSepoliaConfig();

        vm.startBroadcast();
        PredictionMarket market = new PredictionMarket(
            config.finder, config.currency, config.optimisticOracleV3, 0xD12355D121eDee77DbC4D1Abdf01A965409170e4
        );
        console2.log("PredictionMarket deployed to: ", address(market));
        vm.stopBroadcast();
        return market;
    }
}
