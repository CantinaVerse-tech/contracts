// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { LastManStanding } from "../../src/games/LastManStanding.sol";

contract DeployLastManStanding is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        LastManStanding lastManStanding = new LastManStanding();
        console2.log("LastManStanding Contract deployed to: ", address(lastManStanding));
        vm.stopBroadcast();
    }
}
