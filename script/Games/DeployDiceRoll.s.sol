// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { DiceRollCasino } from "../../src/games/DiceRoll.sol";

contract DeployDiceRoll is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        DiceRollCasino diceRollCasino = new DiceRollCasino(0);
        console2.log("DiceRollCasino Contract deployed to: ", address(diceRollCasino));
        vm.stopBroadcast();
    }
}
