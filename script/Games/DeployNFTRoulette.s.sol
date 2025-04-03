// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { NFTRoulette } from "../../src/games/NFTRoulette.sol";

contract DeployNFTRoulette is Script {
    function run() external returns (NFTRoulette) {
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
        NFTRoulette game = new NFTRoulette(0x0C007e2aF454d05BEd6b60E226BD9E480441d1B1);
        vm.stopBroadcast();

        console2.log("NFTRoulette deployed at:", address(game));
        console2.log("Initial owner:", config.initialOwner);
        console2.log("Service fee:", config.serviceFee);

        return game;
    }
}
