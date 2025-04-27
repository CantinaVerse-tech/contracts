// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { CantinaToken } from "../../src/governance/CantinaToken.sol";

contract DeployFactoryTokenContract is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        CantinaToken cantinaToken = new CantinaToken(msg.sender, msg.sender, msg.sender, msg.sender);
        console2.log("CantinaToken Contract deployed to: ", address(cantinaToken));
        vm.stopBroadcast();
    }
}
