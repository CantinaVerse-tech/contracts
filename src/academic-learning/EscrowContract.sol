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
}
