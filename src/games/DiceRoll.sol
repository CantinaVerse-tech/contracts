// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract DiceRollCasino {
    address public owner;
    uint256 public minimumBet;
    uint256 public jackpot;

    // Event to notify of a new game result
    event GameResult(address indexed player, uint256 betAmount, uint256 diceRoll, bool won);

    constructor(uint256 _minimumBet) {
        owner = msg.sender;
        minimumBet = _minimumBet;
        jackpot = 0;
    }

    // Function to place a bet
    function placeBet(uint256 _guess) public payable {
        require(msg.value >= minimumBet, "Bet amount is too low.");
        require(_guess >= 1 && _guess <= 6, "Guess must be between 1 and 6.");

        uint256 betAmount = msg.value;
        jackpot += betAmount;

        // Simulate a dice roll
        uint256 diceRoll = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 6) + 1;

        bool won = _guess == diceRoll;
        if (won) {
            uint256 payout = jackpot;
            jackpot = 0;
            payable(msg.sender).transfer(payout); // Send the winnings to the player
        }

        emit GameResult(msg.sender, betAmount, diceRoll, won);
    }

    // Function to allow the owner to withdraw accumulated jackpot
    function withdrawJackpot() public {
        require(msg.sender == owner, "Only the owner can withdraw.");
        require(jackpot > 0, "No jackpot to withdraw.");

        uint256 payout = jackpot;
        jackpot = 0;
        payable(owner).transfer(payout);
    }

    // Function to change the minimum bet amount
    function changeMinimumBet(uint256 _newMinimumBet) public {
        require(msg.sender == owner, "Only the owner can change the minimum bet.");
        minimumBet = _newMinimumBet;
    }
}
