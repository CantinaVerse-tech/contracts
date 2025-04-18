// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ERC20Pausable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

/**
 * @title TokenContract
 * @author CantinaVerse
 * @dev A customizable ERC20 token contract with minting, burning, and pausable features.
 * This contract allows the owner to mint and burn tokens based on configuration. Additionally,
 * the contract can pause or unpause all token transfers.
 *
 * Inherits from OpenZeppelin's ERC20, ERC20Pausable, and Ownable contracts.
 */
contract TokenContract is ERC20, ERC20Pausable, Ownable {
    ////////////////////
    // Custom Errors //
    //////////////////
    error MintingIsDisabled();
    error BurningIsDisabled();
    error MaxSupplyReached();

    //////////////////////
    // State variables //
    ////////////////////
    // @dev Initial supply of the token minted at deployment
    uint256 private initialSupply;

    // @dev Max supply of the token
    uint256 private maxSupply;

    // @dev Total supply of the token
    bool private supplyCapEnabled;

    // @dev Whether the token can be minted
    bool private canMint;

    // @dev Whether the token can be burned
    bool private canBurn;

    /////////////
    // Events //
    ///////////
    // @dev Emit when a new token is minted
    event Mint(address indexed from, uint256 indexed amount);

    // @dev Emit when a token is burned
    event Burn(address indexed from, uint256 indexed amount);

    ////////////////
    // Functions //
    //////////////
    /**
     * @dev Deploys the token contract, initializes the token with a name, symbol, and initial supply,
     * and sets the owner, minting, burning, and supply cap configurations.
     *
     * @param initialOwner The address that will initially own the token contract.
     * @param tokenName The name of the token (e.g., "MyToken").
     * @param tokenSymbol The symbol of the token (e.g., "MTK").
     * @param _initialSupply The initial token supply minted to the owner.
     * @param _maxSupply The maximum supply that can be minted (if capped).
     * @param _canMint Boolean indicating whether minting is allowed.
     * @param _canBurn Boolean indicating whether burning is allowed.
     * @param _supplyCapEnabled Boolean indicating whether a maximum supply cap is enforced.
     */
    constructor(
        address initialOwner,
        string memory tokenName,
        string memory tokenSymbol,
        uint256 _initialSupply,
        uint256 _maxSupply,
        bool _canMint,
        bool _canBurn,
        bool _supplyCapEnabled
    )
        ERC20(tokenName, tokenSymbol)
    {
        initialOwner = msg.sender;
        initialSupply = _initialSupply;
        maxSupply = _maxSupply;
        canMint = _canMint;
        canBurn = _canBurn;
        supplyCapEnabled = _supplyCapEnabled;
        _mint(initialOwner, _initialSupply);
    }

    /**
     * @dev Mints new tokens to the specified address.
     * Can only be called by the contract owner.
     *
     * Emits a {Mint} event.
     *
     * Requirements:
     * - `canMint` must be true.
     * - If `supplyCapEnabled` is true, the total supply after minting must not exceed `maxSupply`.
     *
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        if (!canMint) {
            revert MintingIsDisabled();
        }
        if (supplyCapEnabled) {
            if (totalSupply() + amount > maxSupply) {
                revert MaxSupplyReached();
            }
        }
        _mint(to, amount);
        emit Mint(to, amount);
    }

    /**
     * @dev Burns a specified amount of tokens from the caller's account.
     *
     * Emits a {Burn} event.
     *
     * Requirements:
     * - `canBurn` must be true.
     *
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) external {
        if (!canBurn) {
            revert BurningIsDisabled();
        }
        _burn(msg.sender, amount);
        emit Burn(msg.sender, amount);
    }

    /**
     * @dev Pauses all token transfers.
     * Can only be called by the contract owner.
     *
     * Emits a {Paused} event from the parent `ERC20Pausable` contract.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all token transfers.
     * Can only be called by the contract owner.
     *
     * Emits an {Unpaused} event from the parent `ERC20Pausable` contract.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    ////////////////
    // Overrides //
    //////////////
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
