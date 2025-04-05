// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { AMMContract } from "../../src/predictionmarket/AMMContract.sol";

contract DeployAMMContract is Script {
    function run() external returns (AMMContract) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        if (block.chainid == 31_337) {
            config = helperConfig.getAnvilConfig();
        } else if (block.chainid == 11_155_111) {
            config = helperConfig.getSepoliaConfig();
        } else if (block.chainid == 8453) {
            config = helperConfig.getBaseMainnetConfig();
        } else if (block.chainid == 84_532) {
            config = helperConfig.getBaseSepoliaConfig();
        } else if (block.chainid == 10) {
            config = helperConfig.getOpMainnetConfig();
        } else if (block.chainid == 11_155_420) {
            config = helperConfig.getOPSepoliaConfig();
        } else if (block.chainid == 34_443) {
            config = helperConfig.getModeMainnetConfig();
        } else {
            revert("Unsupported network");
        }

        vm.startBroadcast();
        AMMContract amm = new AMMContract(
            0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,
            0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4,
            0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2
        );
        vm.stopBroadcast();

        console2.log("AMMContract deployed at:", address(amm));
        console2.log("Initial owner:", config.initialOwner);

        return amm;
    }
}
