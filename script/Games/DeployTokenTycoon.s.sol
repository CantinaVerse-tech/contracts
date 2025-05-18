// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { TokenTycoon } from "../../src/games/TokenTycoon.sol";

contract DeployTokenTycoon is Script {
    function run() external returns (TokenTycoon) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        TokenTycoon tokenTycoon = new TokenTycoon();
        vm.stopBroadcast();

        console2.log("TokenTycoon deployed at:", address(tokenTycoon));

        return tokenTycoon;
    }
}
