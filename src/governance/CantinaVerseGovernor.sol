// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { Governor } from "@openzeppelin/contracts/governance/Governor.sol";
import { GovernorCountingSimple } from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import { GovernorSettings } from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import { GovernorTimelockControl } from "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";
import { GovernorVotes } from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import { GovernorVotesQuorumFraction } from
    "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { TimelockController } from "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title CantinaVerseGovernor
 * @author CantinaVerse-Tech
 * @notice Governance contract for CantinaVerse ecosystem
 * @dev Implements OpenZeppelin Governor with multiple extensions
 */
contract CantinaVerseGovernor is
    Governor,
    GovernorSettings,
    GovernorCountingSimple,
    GovernorVotes,
    GovernorVotesQuorumFraction,
    GovernorTimelockControl
{
    // Events
    event GovernanceParametersUpdated(uint256 votingDelay, uint256 votingPeriod, uint256 proposalThreshold);
    event QuorumUpdated(uint256 newQuorum);

    /**
     * @notice Constructor for CantinaVerseGovernor
     * @param _token The token used for voting
     * @param _timelock The timelock controller used for proposal execution
     */
    constructor(
        IVotes _token,
        TimelockController _timelock
    )
        Governor("CantinaVerse")
        // 1 day voting delay, 1 week voting period, 3 token threshold
        GovernorSettings(1 days, 1 weeks, 3 * 10 ** 18)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4) // 4% quorum
        GovernorTimelockControl(_timelock)
    { }

    /**
     * @notice Updates governance parameters
     * @param newVotingDelay New voting delay
     * @param newVotingPeriod New voting period
     * @param newProposalThreshold New proposal threshold
     * @dev Only callable via governance process
     */
    function updateGovernanceParameters(
        uint256 newVotingDelay,
        uint256 newVotingPeriod,
        uint256 newProposalThreshold
    )
        external
        onlyGovernance
    {
        _setVotingDelay(newVotingDelay);
        _setVotingPeriod(newVotingPeriod);
        _setProposalThreshold(newProposalThreshold);

        emit GovernanceParametersUpdated(newVotingDelay, newVotingPeriod, newProposalThreshold);
    }

    /**
     * @notice Updates the quorum numerator (percentage)
     * @param newQuorumNumerator New quorum numerator
     * @dev Only callable via governance process
     */
    function updateQuorumNumerator(uint256 newQuorumNumerator) external onlyGovernance {
        _updateQuorumNumerator(newQuorumNumerator);

        emit QuorumUpdated(newQuorumNumerator);
    }

    /**
     * @notice Allows users to see what they can currently vote on
     * @param voter The address to check
     * @return activeProposalIds Array of active proposal IDs
     */
    function getActiveProposalsForVoter(address voter) external view returns (uint256[] memory activeProposalIds) {
        // Get total proposals count from storage
        uint256 proposalCount = proposalCount();

        // First pass to count active proposals
        uint256 activeCount = 0;
        for (uint256 i = 0; i < proposalCount; i++) {
            uint256 proposalId = proposalAt(i);
            ProposalState proposalState = state(proposalId);

            if (proposalState == ProposalState.Active && !hasVoted(proposalId, voter)) {
                activeCount++;
            }
        }
    }
}
