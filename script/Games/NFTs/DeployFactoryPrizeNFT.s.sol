// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../../HelperConfig.s.sol";
import { FactoryPrizeNFT } from "../../../src/games/NFTRoulette/FactoryPrizeNFT.sol";

contract DeployFactoryPrizeNFT is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        FactoryPrizeNFT factory = new FactoryPrizeNFT();
        vm.stopBroadcast();

        console2.log("FactoryPrizeNFT deployed at:", address(factory));
    }
}
