// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { FactoryNFTContract } from "../../../src/marketplace/FactoryNFTContract.sol";

contract DeployFactoryNFTContract is Script {
    function run() external returns (FactoryNFTContract) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        vm.startBroadcast();
        FactoryNFTContract factory = new FactoryNFTContract(msg.sender, 0);
        vm.stopBroadcast();

        console2.log("FactoryNFTContract deployed at:", address(factory));
        console2.log("Initial owner:", msg.sender);

        return factory;
    }
}
