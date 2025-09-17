// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { TokenFactory } from "../../src/tokencreation/CreateToken.sol";

contract DeployAll is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        TokenFactory factoryToken = new TokenFactory(0x6A1910944a98BE050a8b5E32FC49e9291c40D9c8);
        console2.log("TokenFactory deployed to: ", address(factoryToken));
        vm.stopBroadcast();
    }
}
