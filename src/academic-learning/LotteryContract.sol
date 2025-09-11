// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title LotteryContract
 * @dev Simple lottery system with ticket purchases and random winner selection
 * Educational contract for learning randomness and lottery mechanics
 */
contract LotteryContract {
    enum LotteryState {
        OPEN,
        CALCULATING,
        CLOSED
    }

    struct Lottery {
        uint256 id;
        uint256 ticketPrice;
        uint256 startTime;
        uint256 endTime;
        address[] players;
        address winner;
        uint256 prizePool;
        LotteryState state;
        bool prizeClaimed;
        uint256 maxTickets;
        mapping(address => uint256) ticketCount;
    }

    mapping(uint256 => Lottery) public lotteries;
    uint256 public currentLotteryId;
    uint256 public constant HOUSE_FEE_PERCENT = 5; // 5% house fee
    address public owner;
    uint256 public totalLotteries;

    event LotteryCreated(uint256 indexed lotteryId, uint256 ticketPrice, uint256 duration, uint256 maxTickets);
    event TicketPurchased(uint256 indexed lotteryId, address indexed player, uint256 ticketCount, uint256 totalCost);
    event LotteryEnded(uint256 indexed lotteryId, uint256 totalPlayers, uint256 prizePool);
    event WinnerSelected(uint256 indexed lotteryId, address indexed winner, uint256 prize);
    event PrizeClaimed(uint256 indexed lotteryId, address indexed winner, uint256 amount);

}
