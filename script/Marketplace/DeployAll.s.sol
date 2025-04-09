// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { AuctionEndChecker } from "../../src/marketplace/AuctionEndChecker.sol";
import { IMarketPlace } from "../../src/marketplace/interfaces/IMarketPlace.sol";
import { FactoryNFTContract } from "../../../src/marketplace/FactoryNFTContract.sol";
import { MarketPlace } from "../../../src/marketplace/MarketPlace.sol";

contract DeployAll is Script { }
