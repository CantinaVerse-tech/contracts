// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleToken
 * @author CantinaVerse-Tech
 * @notice A simple ERC20 token with fixed supply and metadata functionality
 * @dev This contract creates an ERC20 token with a fixed maximum supply that is minted
 *      entirely to the creator upon deployment. It includes additional metadata fields
 *      for description and image URL, making it suitable for token projects that need
 *      basic metadata storage on-chain.
 */
contract SimpleToken is ERC20, Ownable {
/// @notice The number of decimal places for the token
    /// @dev Stored privately and accessed via decimals() function from ERC20
    uint8 private _decimals;
    
    /// @notice The maximum supply of tokens that can ever exist
    /// @dev This is set during construction and represents the total supply since no minting occurs after deployment
    uint256 public maxSupply;
    
    /// @notice A description of the token's purpose or characteristics
    /// @dev Stored privately for gas optimization, accessible via getter function
    string private _description;
    
    /// @notice URL pointing to an image representing the token
    /// @dev Stored privately for gas optimization, accessible via getter function
    string private _imageUrl;
    
    /// @notice The address that created this token contract
    /// @dev This is set during construction and represents the original creator
    address public creator;

    /**
     * @notice Emitted when a new token is successfully created and deployed
     * @param token The address of the newly created token contract
     * @param creator The address of the account that created the token
     * @param name The name of the token
     * @param symbol The symbol of the token
     * @param totalSupply The total supply of tokens minted to the creator
     */
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
