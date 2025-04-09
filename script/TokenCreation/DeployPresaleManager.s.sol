// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { PresaleManager } from "../../src/tokencreation/PresaleManager.sol";

contract DeployPresaleManager is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        PresaleManager presaleManager = new PresaleManager(
            0xd7e9C75C6C05FdE929cAc19bb887892de78819B7,
            0xA8c5613E1B663381D0930A782295D55306D8a434,
            0x90E2D21d6945806c8b3139c7b54218ADF921aeD1,
            0x6A1910944a98BE050a8b5E32FC49e9291c40D9c8
        );
        console2.log("PresaleManager deployed to: ", address(presaleManager));
        vm.stopBroadcast();
    }
}
