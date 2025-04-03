// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { MarketPlace } from "../../../src/marketplace/MarketPlace.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployMarketPlace is Script {
    function run() external returns (MarketPlace) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        if (block.chainid == 31_337) {
            config = helperConfig.getAnvilConfig();
        } else if (block.chainid == 42_220) {
            config = helperConfig.getCeloMainnetConfig();
        } else if (block.chainid == 11_155_111) {
            config = helperConfig.getSepoliaConfig();
        } else if (block.chainid == 84_532) {
            config = helperConfig.getBaseSepoliaConfig();
        } else if (block.chainid == 11_155_420) {
            config = helperConfig.getOPSepoliaConfig();
        } else if (block.chainid == 8453) {
            config = helperConfig.getBaseMainnetConfig();
        } else if (block.chainid == 10) {
            config = helperConfig.getOpMainnetConfig();
        } else if (block.chainid == 34_443) {
            config = helperConfig.getModeMainnetConfig();
        } else {
            revert("Unsupported network");
        }

        vm.startBroadcast();
        MarketPlace marketPlace =
            new MarketPlace(config.initialOwner, config.GelatoDedicatedMsgSender, config.serviceFee);
        vm.stopBroadcast();

        console2.log("marketPlace deployed at:", address(marketPlace));
        console2.log("Initial owner:", config.initialOwner);
        console2.log("GelatoDedicatedMsgSender:", config.GelatoDedicatedMsgSender);
        console2.log("Service fee:", config.serviceFee);

        return marketPlace;
    }
}
