// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { NumberGuessingGame } from "../../src/games/NumberGuessingGame.sol";

contract DeployNumberGuessingGame is Script {
    function run() external returns (NumberGuessingGame) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        NumberGuessingGame numberGuessingGame = new NumberGuessingGame(123, 0, 3);
        vm.stopBroadcast();

        console2.log("NumberGuessingGame deployed at:", address(numberGuessingGame));

        return numberGuessingGame;
    }
}
