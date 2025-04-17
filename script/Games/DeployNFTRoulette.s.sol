// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { NFTRoulette } from "../../src/games/NFTRoulette.sol";

contract DeployNFTRoulette is Script {
    function run() external returns (NFTRoulette) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        NFTRoulette game = new NFTRoulette();
        vm.stopBroadcast();

        console2.log("NFTRoulette deployed at:", address(game));

        return game;
    }
}
