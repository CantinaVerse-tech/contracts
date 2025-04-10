// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Votes } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CantinaToken
 * @author CantinaVerse-Tech
 * @notice Governance token for the CantinaVerse ecosystem with voting capabilities
 * @dev Extends ERC20 with voting extensions to support governance
 */
contract CantinaToken is ERC20, ERC20Permit, ERC20Votes, Ownable { }
