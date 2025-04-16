// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../../HelperConfig.s.sol";
import { FactoryPrizeNFT } from "../../../src/games/NFTRoulette/FactoryPrizeNFT.sol";

contract DeployFactoryPrizeNFT is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        if (block.chainid == 31_337) {
            config = helperConfig.getAnvilConfig();
        } else if (block.chainid == 11_155_111) {
            config = helperConfig.getSepoliaConfig();
        } else if (block.chainid == 8453) {
            config = helperConfig.getBaseMainnetConfig();
        } else if (block.chainid == 84_532) {
            config = helperConfig.getBaseSepoliaConfig();
        } else if (block.chainid == 10) {
            config = helperConfig.getOpMainnetConfig();
        } else if (block.chainid == 11_155_420) {
            config = helperConfig.getOPSepoliaConfig();
        } else if (block.chainid == 34_443) {
            config = helperConfig.getModeMainnetConfig();
        } else {
            revert("Unsupported network");
        }

        vm.startBroadcast();
        FactoryPrizeNFT factory = new FactoryPrizeNFT();
        vm.stopBroadcast();

        console2.log("FactoryPrizeNFT deployed at:", address(factory));
    }
}
