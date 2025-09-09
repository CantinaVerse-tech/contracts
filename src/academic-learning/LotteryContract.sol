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

}
