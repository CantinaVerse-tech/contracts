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
        onlyOwner
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
}
