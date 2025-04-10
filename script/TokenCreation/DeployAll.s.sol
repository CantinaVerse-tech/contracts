// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { PresaleManager } from "../../src/tokencreation/PresaleManager.sol";
import { VestingVault } from "../../src/tokencreation/VestingVault.sol";
import { FactoryTokenContract } from "../../src/tokencreation/FactoryTokenContract.sol";
import { LiquidityManager } from "../../src/tokencreation/LiquidityManager.sol";

contract DeployAll is Script {
    function run() external {
        HelperConfig helperConfig = new HelperConfig();
        vm.startBroadcast();
        VestingVault vestingVault = new VestingVault(0xA8c5613E1B663381D0930A782295D55306D8a434);
        LiquidityManager liquidityManager =
            new LiquidityManager(0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4, 0xd7e9C75C6C05FdE929cAc19bb887892de78819B7);
        FactoryTokenContract factoryToken =
            new FactoryTokenContract(address(liquidityManager), 0xd7e9C75C6C05FdE929cAc19bb887892de78819B7);
        PresaleManager presaleManager = new PresaleManager(
            0xd7e9C75C6C05FdE929cAc19bb887892de78819B7,
            0xA8c5613E1B663381D0930A782295D55306D8a434,
            address(vestingVault),
            address(liquidityManager)
        );
        console2.log("VestingVault deployed to: ", address(vestingVault));
        console2.log("LiquidityManager deployed to: ", address(liquidityManager));
        console2.log("FactoryTokenContract deployed to: ", address(factoryToken));
        console2.log("PresaleManager deployed to: ", address(presaleManager));

        vm.stopBroadcast();
    }
}
