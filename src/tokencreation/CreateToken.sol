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

   /**
     * @notice Creates a new SimpleToken with specified parameters
     * @dev Initializes the ERC20 token with name and symbol, sets up ownership,
     *      and mints the entire supply to the creator address
     * @param name The human-readable name of the token (e.g., "My Token")
     * @param symbol The ticker symbol of the token (e.g., "MTK")
     * @param decimals_ The number of decimal places for token amounts (typically 18)
     * @param totalSupply The total amount of tokens to create (in wei units)
     * @param description A text description of the token's purpose
     * @param imageUrl A URL pointing to an image representing the token
     * @param creator_ The address that will own the contract and receive all tokens
     */
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

   /**
     * @notice Returns the number of decimal places for the token
     * @dev Overrides the ERC20 decimals() function to return custom decimals value
     * @return The number of decimal places (e.g., 18 for most tokens)
     */
        function decimals() public view override returns (uint8) {
        return _decimals;
    }


 /**
     * @notice Returns the description of the token
     * @dev Getter function for the private _description variable
     * @return The token's description string
     */
        function description() public view returns (string memory) {
        return _description;
    }

    /**
     * @notice Returns the image URL of the token
     * @dev Getter function for the private _imageUrl variable
     * @return The token's image URL string
     */
    function imageUrl() public view returns (string memory) {
        return _imageUrl;
    }

    /**
     * @notice Burns tokens from the caller's account
     * @dev Reduces the total supply by destroying tokens from msg.sender
     * @param amount The number of tokens to burn (in wei units)
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @notice Burns tokens from a specified account using allowance
     * @dev Allows approved spenders to burn tokens from another account
     *      Requires sufficient allowance from the account being burned from
     * @param account The address to burn tokens from
     * @param amount The number of tokens to burn (in wei units)
     */
    function burnFrom(address account, uint256 amount) public {
    _spendAllowance(account, msg.sender, amount);
    _burn(account, amount);
    }
}

/**
 * @title TokenFactory
 * @author CantinaVerse-Tech
 * @notice A factory contract for creating and managing ERC20 tokens
 * @dev This contract provides functionality to deploy new TokenCreation contracts
 *      with a fee mechanism. It maintains records of all created tokens and provides
 *      various query functions for retrieving token information. The contract supports
 *      pagination for efficient data retrieval and includes administrative functions
 *      for managing fees and recipients.
 */
contract TokenFactory {
    /**
     * @notice Structure containing comprehensive information about a created token
     * @dev Used for storing and retrieving token metadata in mappings and arrays
     * @param tokenAddress The deployed contract address of the token
     * @param creator The address that created the token
     * @param name The human-readable name of the token
     * @param symbol The ticker symbol of the token
     * @param totalSupply The total supply of tokens created
     * @param description A text description of the token
     * @param imageUrl URL pointing to the token's image
     * @param createdAt Timestamp when the token was created
     */
    struct TokenInfo {
        address tokenAddress;
        address creator;
        string name;
        string symbol;
        uint256 totalSupply;
        string description;
        string imageUrl;
        uint256 createdAt;
    }
}


