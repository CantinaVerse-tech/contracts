// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NumberGuesser {
    bytes32 private secretHash;
    address public winner;
    bool public gameActive = true;

    constructor(uint256 _secretNumber) {
        secretHash = keccak256(abi.encodePacked(_secretNumber));
    }

    /**
     * @notice Allows a player to guess the secret number.
     * @param _guess The player's guess.
     * @dev If the guess is correct, the game ends and the player becomes the winner.
     */
    function guess(uint256 _guess) external {
        require(gameActive, "Game over");

        if (keccak256(abi.encodePacked(_guess)) == secretHash) {
            winner = msg.sender;
            gameActive = false;
        }
    }
}
