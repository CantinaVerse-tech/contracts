// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { LiquidityManager } from "../../src/tokencreation/LiquidityManager.sol";

contract DeployLiquidityManager is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        LiquidityManager liquidityManager =
            new LiquidityManager(0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4, 0xd7e9C75C6C05FdE929cAc19bb887892de78819B7);
        console2.log("LiquidityManager deployed to: ", address(liquidityManager));
        vm.stopBroadcast();
    }
}
