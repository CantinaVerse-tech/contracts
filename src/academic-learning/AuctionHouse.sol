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

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => mapping(address => uint256)) public pendingReturns;

    uint256 public auctionCounter;
    uint256 public constant AUCTION_FEE_PERCENT = 2; // 2% fee
    address public owner;

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed seller,
        string itemName,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 duration
    );

    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount, uint256 timestamp);

    event AuctionEnded(uint256 indexed auctionId, address winner, uint256 winningBid);

    event AuctionSettled(uint256 indexed auctionId, uint256 sellerAmount, uint256 fee);

    event AuctionCancelled(uint256 indexed auctionId);

    event BidWithdrawn(uint256 indexed auctionId, address indexed bidder, uint256 amount);

    modifier onlySeller(uint256 auctionId) {
        require(msg.sender == auctions[auctionId].seller, "Only seller can call");
        _;
    }

    modifier auctionExists(uint256 auctionId) {
        require(auctionId < auctionCounter, "Auction does not exist");
        _;
    }

    modifier auctionActive(uint256 auctionId) {
        require(auctions[auctionId].state == AuctionState.ACTIVE, "Auction not active");
        require(block.timestamp < auctions[auctionId].endTime, "Auction ended");
        _;
    }

    modifier auctionEnded(uint256 auctionId) {
        require(
            auctions[auctionId].state == AuctionState.ENDED || block.timestamp >= auctions[auctionId].endTime,
            "Auction not ended"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a new auction
     * @param itemName Name of the item being auctioned
     * @param description Description of the item
     * @param startingPrice Minimum starting bid
     * @param reservePrice Minimum price for sale (can be 0)
     * @param durationHours Duration of auction in hours
     */
    function createAuction(
        string memory itemName,
        string memory description,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 durationHours
    ) external returns (uint256) {
        require(bytes(itemName).length > 0, "Item name required");
        require(startingPrice >= 0, "Starting price must 0 or greater");
        require(reservePrice >= startingPrice, "Reserve price must be >= starting price");
        require(durationHours > 0 && durationHours <= 168, "Duration must be 1-168 hours"); // Max 1 week

        uint256 auctionId = auctionCounter++;
        uint256 endTime = block.timestamp + (durationHours * 1 hours);

        auctions[auctionId] = Auction({
            seller: payable(msg.sender),
            itemName: itemName,
            description: description,
            startingPrice: startingPrice,
            reservePrice: reservePrice,
            highestBid: 0,
            highestBidder: payable(address(0)),
            startTime: block.timestamp,
            endTime: endTime,
            state: AuctionState.ACTIVE,
            settled: false,
            totalBids: 0
        });

        emit AuctionCreated(auctionId, msg.sender, itemName, startingPrice, reservePrice, durationHours);

        return auctionId;
    }
}
