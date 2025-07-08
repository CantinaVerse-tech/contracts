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

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Create a new escrow agreement
     * @param seller Address of the seller
     * @param arbiter Address of the neutral arbiter
     * @param description Description of the goods/services
     * @param deadlineHours Hours until escrow expires
     */
    function createEscrow(
        address payable seller,
        address arbiter,
        string memory description,
        uint256 deadlineHours
    )
        external
        payable
        returns (uint256)
    {
        require(seller != address(0), "Invalid seller address");
        require(arbiter != address(0), "Invalid arbiter address");
        require(seller != msg.sender, "Seller cannot be buyer");
        require(arbiter != msg.sender && arbiter != seller, "Arbiter must be neutral");
        require(deadlineHours > 0 && deadlineHours <= 8760, "Invalid deadline"); // Max 1 year
        require(msg.value > 0, "Must deposit payment");

        uint256 escrowId = escrowCounter++;
        uint256 deadline = block.timestamp + (deadlineHours * 1 hours);

        escrows[escrowId] = Escrow({
            buyer: payable(msg.sender),
            seller: seller,
            arbiter: arbiter,
            amount: msg.value,
            description: description,
            state: EscrowState.AWAITING_DELIVERY,
            buyerApproved: false,
            sellerApproved: false,
            createdAt: block.timestamp,
            deadline: deadline
        });

        emit EscrowCreated(escrowId, msg.sender, seller, arbiter, msg.value, description);
        emit PaymentDeposited(escrowId, msg.value);

        return escrowId;
    }

    /**
     * @notice Deposit payment into the escrow
     * @param escrowId ID of the escrow agreement
     * @dev Buyer confirms delivery and approves release of funds
     */
    function confirmDelivery(uint256 escrowId)
        external
        escrowExists(escrowId)
        onlyBuyer(escrowId)
        inState(escrowId, EscrowState.AWAITING_DELIVERY)
    {
        escrows[escrowId].buyerApproved = true;
        emit DeliveryConfirmed(escrowId);

        _tryCompleteEscrow(escrowId);
    }

    /**
     * @notice Deposit payment into the escrow
     * @param escrowId ID of the escrow agreement
     * @dev Seller acknowledges completion and requests payment
     */
    function requestPayment(uint256 escrowId)
        external
        escrowExists(escrowId)
        onlySeller(escrowId)
        inState(escrowId, EscrowState.AWAITING_DELIVERY)
    {
        escrows[escrowId].sellerApproved = true;
        _tryCompleteEscrow(escrowId);
    }

    /**
     * @notice Internal function to complete escrow if both parties approve
     * @param escrowId ID of the escrow agreement
     * @dev Raise a dispute - can be called by buyer or seller
     */
    function raiseDispute(uint256 escrowId)
        external
        escrowExists(escrowId)
        inState(escrowId, EscrowState.AWAITING_DELIVERY)
    {
        require(
            msg.sender == escrows[escrowId].buyer || msg.sender == escrows[escrowId].seller,
            "Only buyer or seller can raise dispute"
        );

        escrows[escrowId].state = EscrowState.DISPUTED;
        emit DisputeRaised(escrowId, msg.sender);
    }

    /**
     * @notice Resolve dispute between buyer and seller and release funds
     * @param escrowId The escrow ID
     * @param buyerWins True if buyer wins, false if seller wins
     * @dev Arbiter resolves dispute
     */
    function resolveDispute(
        uint256 escrowId,
        bool buyerWins
    )
        external
        escrowExists(escrowId)
        onlyArbiter(escrowId)
        inState(escrowId, EscrowState.DISPUTED)
    {
        if (buyerWins) {
            _refundBuyer(escrowId);
        } else {
            _releaseFundsToSeller(escrowId);
        }

        emit DisputeResolved(escrowId, buyerWins);
    }

    /**
     * @notice Claim refund if deadline has passed and delivery not confirmed
     * @param escrowId The escrow ID
     * @dev Allow refund if deadline has passed and delivery not confirmed
     */
    function claimRefund(uint256 escrowId)
        external
        escrowExists(escrowId)
        onlyBuyer(escrowId)
        inState(escrowId, EscrowState.AWAITING_DELIVERY)
    {
        require(block.timestamp > escrows[escrowId].deadline, "Deadline not reached");
        require(!escrows[escrowId].buyerApproved, "Delivery already confirmed");

        _refundBuyer(escrowId);
    }
}
