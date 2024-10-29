// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { AuctionEndChecker } from "../src/marketplace/AuctionEndChecker.sol";
import { IMarketPlace } from "../src/marketplace/interfaces/IMarketPlace.sol";

contract DeployAuctionEndChecker is Script {
    function run() external returns (AuctionEndChecker) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config;

        if (block.chainid == 31_337) {
            config = helperConfig.getAnvilConfig();
        } else if (block.chainid == 11_155_111) {
            config = helperConfig.getSepoliaConfig();
        } else if (block.chainid == 8453) {
            config = helperConfig.getBaseMainnetConfig();
        } else if (block.chainid == 10) {
            config = helperConfig.getOpMainnetConfig();
        } else if (block.chainid == 34_443) {
            config = helperConfig.getModeMainnetConfig();
        } else {
            revert("Unsupported network");
        }

        vm.startBroadcast();
        IMarketPlace marketPlace = IMarketPlace(0x17CF06244a8b00Ec60B24EAC40B994e543C1c5BD);
        AuctionEndChecker auctionEndChecker = new AuctionEndChecker(marketPlace);
        vm.stopBroadcast();

        console2.log("AuctionEndChecker deployed at:", address(auctionEndChecker));
        console2.log("Marketplace Address:", address(marketPlace));

        return auctionEndChecker;
    }
}
