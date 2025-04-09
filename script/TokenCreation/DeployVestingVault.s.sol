// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { VestingVault } from "../../src/tokencreation/VestingVault.sol";

contract DeployVestingVault is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        VestingVault vestingVault = new VestingVault(0xA8c5613E1B663381D0930A782295D55306D8a434);
        console2.log("VestingVault deployed to: ", address(vestingVault));
        vm.stopBroadcast();
    }
}
