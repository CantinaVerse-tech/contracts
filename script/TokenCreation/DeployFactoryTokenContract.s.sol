// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { FactoryTokenContract } from "../../src/tokencreation/FactoryTokenContract.sol";

contract DeployFactoryTokenContract is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        FactoryTokenContract factoryToken = new FactoryTokenContract(
            0x6A1910944a98BE050a8b5E32FC49e9291c40D9c8, 0xd7e9C75C6C05FdE929cAc19bb887892de78819B7
        );
        console2.log("FactoryTokenContract deployed to: ", address(factoryToken));
        vm.stopBroadcast();
    }
}
