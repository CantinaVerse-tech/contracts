// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title AuctionHouse
 * @dev English auction system with bidding, withdrawal, and settlement
 * Educational contract for learning auction mechanics
 */
contract AuctionHouse {
    enum AuctionState {
        ACTIVE,
        ENDED,
        CANCELLED
    }
}
