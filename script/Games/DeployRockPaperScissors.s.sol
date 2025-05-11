// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { RockPaperScissors } from "../../src/games/RockPaperScissors.sol";

contract DeployRockPaperScissors is Script {
    function run() external returns (RockPaperScissors) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        RockPaperScissors rockPaperScissors = new RockPaperScissors();
        vm.stopBroadcast();

        console2.log("RockPaperScissors deployed at:", address(rockPaperScissors));

        return rockPaperScissors;
    }
}
