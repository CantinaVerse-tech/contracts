// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingContract is Ownable {
    using SafeERC20 for IERC20;

    constructor(address initialOwner) { }
}
