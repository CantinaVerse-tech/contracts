// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import { ILiquidityManager } from "./interfaces/ILiquidityManager.sol";
import { IVestingVault } from "./interfaces/IVestingVault.sol";

contract PresaleManager is Ownable { }
