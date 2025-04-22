// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DiceRollCasino is Ownable, ReentrancyGuard {
    // State variables
    uint256 public minimumBet;
    uint256 public jackpot;

    // Event to notify of a new game result
    event GameResult(address indexed player, uint256 betAmount, uint256 diceRoll, bool won);
    event MinimumBetChanged(uint256 newMinimumBet);
    event JackpotWithdrawn(uint256 amount);
    event FundsDeposited(address indexed from, uint256 amount);

    /**
     * @notice Constructor
     * @param _minimumBet The minimum bet amount for the game
     * @dev Initializes the contract with the specified minimum bet amount
     */
    constructor(uint256 _minimumBet) {
        minimumBet = _minimumBet;
    }

    /**
     * @notice Player places a bet guessing a dice roll (1-6)
     * @param _guess The number the player is guessing
     * @dev Requires the player to send at least the minimum bet amount
     */
    function placeBet(uint256 _guess) external payable nonReentrant {
        require(msg.value >= minimumBet, "Bet too low");
        require(_guess >= 1 && _guess <= 6, "Guess must be between 1 and 6");

        jackpot += msg.value;

        uint256 diceRoll = (uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.difficulty))) % 6) + 1;

        bool won = (_guess == diceRoll);

        if (won) {
            uint256 payout = jackpot;
            jackpot = 0;
            (bool success,) = payable(msg.sender).call{ value: payout }("");
            require(success, "Payout failed");
        }

        emit GameResult(msg.sender, msg.value, diceRoll, won);
    }

    /**
     * @notice Owner withdraws the jackpot
     */
    function withdrawJackpot() external onlyOwner nonReentrant {
        require(jackpot > 0, "No jackpot to withdraw");
        uint256 amount = jackpot;
        jackpot = 0;
        (bool success,) = payable(owner()).call{ value: amount }("");
        require(success, "Withdraw failed");

        emit JackpotWithdrawn(amount);
    }

    /**
     * @notice Owner changes the minimum bet
     * @param _newMinimumBet New minimum bet amount
     */
    function changeMinimumBet(uint256 _newMinimumBet) external onlyOwner {
        minimumBet = _newMinimumBet;
        emit MinimumBetChanged(_newMinimumBet);
    }

    /**
     * @notice Allow contract to receive ETH (for seeding jackpot or top-up)
     */
    receive() external payable {
        jackpot += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }
}
