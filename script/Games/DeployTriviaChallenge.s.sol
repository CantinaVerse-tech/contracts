// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { TriviaChallenge } from "../../src/games/TriviaChallenge.sol";

contract DeployTriviaChallenge is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        TriviaChallenge triviaChallenge = new TriviaChallenge();
        console2.log("TriviaChallenge Contract deployed to: ", address(triviaChallenge));
        vm.stopBroadcast();
    }
}
