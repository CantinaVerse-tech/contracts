// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenCreation
 * @dev Basic ERC20 token that can be deployed by the factory
 */
 contract TokenCreation is ERC20, Ownable {

// Storage Variables
        uint8 private _decimals;
    uint256 public maxSupply;
    string private _description;
    string private _imageUrl;
    address public creator;
}
