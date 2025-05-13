// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { TicTacToe } from "../../src/games/TicTacToe.sol";

contract DeployTicTacToe is Script {
    function run() external returns (TicTacToe) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        TicTacToe ticTacToe = new TicTacToe();
        vm.stopBroadcast();

        console2.log("TicTacToe deployed at:", address(ticTacToe));

        return ticTacToe;
    }
}
