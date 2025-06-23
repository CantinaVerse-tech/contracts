// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

contract SimplePoll {
    bytes32 public question;
    mapping(address => bool) public votes; // true = yes, false = no
    mapping(address => bool) public hasVoted;
    uint256 public yesCount;
    uint256 public noCount;

    constructor(bytes32 _question) {
        question = _question;
    }

    /**
     * @notice This function is for voting
     * @param _vote Is a true/false parameter to see who already voted
     * @dev Anyone can vote.
     */
    function vote(bool _vote) external {
        require(!hasVoted[msg.sender], "Already voted");

        votes[msg.sender] = _vote;
        hasVoted[msg.sender] = true;

        if (_vote) {
            yesCount++;
        } else {
            noCount++;
        }
    }

    /**
     *
     * @return yes is to show the amount of yes votes
     * @return no is to show the amount of no votes
     */
    function getResults() external view returns (uint256 yes, uint256 no) {
        return (yesCount, noCount);
    }
}
