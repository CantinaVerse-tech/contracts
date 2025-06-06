// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { PrizeNFT } from "./PrizeNFT.sol";

/**
 * @title FactoryPrizeNFT
 * @author CantinaVerse-Tech
 * @notice Factory contract to deploy and manage multiple PrizeNFT collections
 * @dev This contract allows for the creation and management of multiple PrizeNFT collections.
 */
contract FactoryPrizeNFT is Ownable {
    // Array to keep track of all deployed PrizeNFT contracts
    address[] public allPrizeNFTs;

    // Event emitted when a new PrizeNFT contract is created
    event PrizeNFTCreated(address indexed prizeNFT, string name, string symbol, string baseURI);

    constructor() { }

    /**
     * @dev Deploys a new PrizeNFT contract
     * @param name Name of the NFT collection
     * @param symbol Symbol of the NFT collection
     * @param baseURI Base URI for token metadata
     * @return prizeNFT Address of the newly deployed PrizeNFT contract
     */
    function createPrizeNFT(
        string memory name,
        string memory symbol,
        string memory baseURI
    )
        external
        returns (address prizeNFT)
    {
        // Deploy a new PrizeNFT contract
        PrizeNFT newPrizeNFT = new PrizeNFT(name, symbol, baseURI);
        // Transfer ownership of the new contract to the owner of the factory
        newPrizeNFT.transferOwnership(owner());
        // Add the new contract's address to the tracking array
        allPrizeNFTs.push(address(newPrizeNFT));
        // Emit an event for the new contract creation
        emit PrizeNFTCreated(address(newPrizeNFT), name, symbol, baseURI);
        return address(newPrizeNFT);
    }

    /**
     * @dev Returns the number of PrizeNFT contracts deployed
     * @return count Number of PrizeNFT contracts
     */
    function getPrizeNFTCount() external view returns (uint256 count) {
        return allPrizeNFTs.length;
    }

    /**
     * @dev Returns the address of a PrizeNFT contract at a specific index
     * @param index Index in the allPrizeNFTs array
     * @return prizeNFT Address of the PrizeNFT contract
     */
    function getPrizeNFT(uint256 index) external view returns (address prizeNFT) {
        require(index < allPrizeNFTs.length, "Index out of bounds");
        return allPrizeNFTs[index];
    }
}
