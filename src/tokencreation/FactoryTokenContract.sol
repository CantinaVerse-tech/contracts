// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TokenContract } from "./TokenContract.sol";
import { ILiquidityManager } from "./interfaces/ILiquidityManager.sol";

contract FactoryTokenContract is Ownable {
    constructor() { }
}
