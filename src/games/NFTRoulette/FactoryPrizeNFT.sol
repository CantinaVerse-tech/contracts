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
contract FactoryPrizeNFT {
    // Array to keep track of all deployed PrizeNFT contracts
    address[] public allPrizeNFTs;
}
