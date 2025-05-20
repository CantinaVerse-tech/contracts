// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { CoinFlip } from "../../../src/games/CoinFlip.sol";

contract DeployCoinFlip is Script {
    function run() external returns (CoinFlip) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        CoinFlip game = new CoinFlip();
        vm.stopBroadcast();

        console2.log("CoinFlip deployed at:", address(game));

        return game;
    }
}
