// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { NFTStakingEvolution } from "../../../src/games/NFTStakingEvolution.sol";

contract DeployStakingEvolution is Script {
    function run() external returns (NFTStakingEvolution) {
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
        NFTStakingEvolution game = new NFTStakingEvolution(0x156b0e52cE557A0E489944f46Bd849BBD81345E5);
        vm.stopBroadcast();

        console2.log("NFTStakingEvolution deployed at:", address(game));
        console2.log("Initial owner:", config.initialOwner);
        console2.log("Service fee:", config.serviceFee);

        return game;
    }
}
