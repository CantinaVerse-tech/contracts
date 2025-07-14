// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CreateToken
 * @author CantinaVerse-Tech
 * @notice
 */
contract SimpleToken is ERC20, Ownable {
    uint8 private _decimals;
    uint256 public maxSupply;
    string private _description;
    string private _imageUrl;
    address public creator;

    event TokenCreated(address indexed token, address indexed creator, string name, string symbol, uint256 totalSupply);
}
