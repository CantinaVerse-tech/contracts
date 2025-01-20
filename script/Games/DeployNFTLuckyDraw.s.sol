// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title DeployFactoryNFTContract
 * @author Shawn Rizo
 * @notice A script to deploy the NFTLuckyDraw game with configurations fetched from a HelperConfig contract.
 */
import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { NFTLuckyDraw } from "../../../src/games/NFTLuckyDraw.sol";

contract DeployNFTLuckyDraw is Script {
    /**
     * @notice Deploys the FactoryNFTContract with the active network configuration.
     * @dev Fetches the active network configuration from the HelperConfig contract and uses it to deploy the
     * FactoryNFTContract.
     * @return The address of the newly deployed FactoryNFTContract.
     */
    function run() external returns (NFTLuckyDraw) {
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
        NFTLuckyDraw game = new NFTLuckyDraw();
        vm.stopBroadcast();

        console2.log("NFTLuckyDraw deployed at:", address(game));
        console2.log("Initial owner:", config.initialOwner);
        console2.log("Service fee:", config.serviceFee);

        return game;
    }
}
