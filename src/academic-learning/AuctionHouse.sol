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

    struct Auction {
        address payable seller;
        string itemName;
        string description;
        uint256 startingPrice;
        uint256 reservePrice;
        uint256 highestBid;
        address payable highestBidder;
        uint256 startTime;
        uint256 endTime;
        AuctionState state;
        bool settled;
        uint256 totalBids;
    }
}
