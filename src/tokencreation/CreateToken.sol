// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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

    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals_,
        uint256 totalSupply,
        string memory description,
        string memory imageUrl,
        address creator_
    )
        ERC20(name, symbol)
        Ownable(creator_)
    {
        _decimals = decimals_;
        maxSupply = totalSupply;
        _description = description;
        _imageUrl = imageUrl;
        creator = creator_;

        // Mint total supply to creator
        _mint(creator_, totalSupply);

        emit TokenCreated(address(this), creator_, name, symbol, totalSupply);
    }
}
