// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Script, console2 } from "forge-std/Script.sol";
import { HelperConfig } from "../HelperConfig.s.sol";
import { PresaleManager } from "../../src/tokencreation/PresaleManager.sol";
import { VestingVault } from "../../src/tokencreation/VestingVault.sol";
import { FactoryTokenContract } from "../../src/tokencreation/FactoryTokenContract.sol";
import { LiquidityManager } from "../../src/tokencreation/LiquidityManager.sol";

contract DeployAll is Script { }
