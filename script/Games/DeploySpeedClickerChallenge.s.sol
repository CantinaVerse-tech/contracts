// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { SpeedClickerChallenge } from "../../../src/games/SpeedClickerChallenge.sol";

contract DeploySpeedClickerChallenge is Script {
    function run() external returns (SpeedClickerChallenge) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        SpeedClickerChallenge speedClickerChallenge = new SpeedClickerChallenge();
        vm.stopBroadcast();

        console2.log("SpeedClickerChallenge deployed at:", address(speedClickerChallenge));

        return speedClickerChallenge;
    }
}
