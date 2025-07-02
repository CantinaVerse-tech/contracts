// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title EscrowContract
 * @author CantinaVerse-Tech
 * @dev Three-party escrow system with buyer, seller, and arbiter
 * Educational contract for learning escrow patterns
 */
contract EscrowContract {
    enum EscrowState {
        AWAITING_PAYMENT,
        AWAITING_DELIVERY,
        COMPLETE,
        DISPUTED,
        REFUNDED
    }

    struct Escrow {
        address payable buyer;
        address payable seller;
        address arbiter;
        uint256 amount;
        string description;
        EscrowState state;
        bool buyerApproved;
        bool sellerApproved;
        uint256 createdAt;
        uint256 deadline;
    }

    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCounter;
    uint256 public constant ESCROW_FEE_PERCENT = 0; // 0% fee
    address public owner;

    event EscrowCreated(
        uint256 indexed escrowId,
        address indexed buyer,
        address indexed seller,
        address arbiter,
        uint256 amount,
        string description
    );
    event PaymentDeposited(uint256 indexed escrowId, uint256 amount);
    event DeliveryConfirmed(uint256 indexed escrowId);
    event DisputeRaised(uint256 indexed escrowId, address indexed disputeRaiser);
    event EscrowCompleted(uint256 indexed escrowId, uint256 sellerAmount, uint256 fee);
    event EscrowRefunded(uint256 indexed escrowId, uint256 refundAmount);
    event DisputeResolved(uint256 indexed escrowId, bool buyerWins);

    modifier onlyBuyer(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].buyer, "Only buyer can call");
        _;
    }

    modifier onlySeller(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].seller, "Only seller can call");
        _;
    }

    modifier onlyArbiter(uint256 escrowId) {
        require(msg.sender == escrows[escrowId].arbiter, "Only arbiter can call");
        _;
    }

    modifier onlyParties(uint256 escrowId) {
        require(
            msg.sender == escrows[escrowId].buyer || msg.sender == escrows[escrowId].seller
                || msg.sender == escrows[escrowId].arbiter,
            "Only escrow parties can call"
        );
        _;
    }

    modifier inState(uint256 escrowId, EscrowState expectedState) {
        require(escrows[escrowId].state == expectedState, "Invalid escrow state");
        _;
    }

    modifier escrowExists(uint256 escrowId) {
        require(escrowId < escrowCounter, "Escrow does not exist");
        _;
    }
}
