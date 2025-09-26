// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interface/IActivityTracker.sol";

/**
 * @title DeFiActivityTracker
 * @dev Tracks DeFi-related activities like swaps, liquidity provision, lending, etc.
 */
contract DeFiActivityTracker {
    // Activity type constants
    bytes32 public constant SWAP = keccak256("SWAP");
    bytes32 public constant LIQUIDITY_ADD = keccak256("LIQUIDITY_ADD");
    bytes32 public constant LIQUIDITY_REMOVE = keccak256("LIQUIDITY_REMOVE");
    bytes32 public constant LENDING = keccak256("LENDING");
    bytes32 public constant BORROWING = keccak256("BORROWING");
    bytes32 public constant STAKING = keccak256("STAKING");
    bytes32 public constant YIELD_FARMING = keccak256("YIELD_FARMING");
    bytes32 public constant NFT_TRADE = keccak256("NFT_TRADE");

    // User activity statistics
    struct UserActivity {
        uint256 totalCount;
        uint256 totalValue;
        uint256 currentStreak;
        uint256 lastActivityDate; // Date in days since epoch
        uint256 lastActivityTimestamp;
        mapping(uint256 => bool) activeDays; // Track active days for streak calculation
    }

    // Nested mapping: user => activityType => UserActivity
    mapping(address => mapping(bytes32 => UserActivity)) private userActivities;
    
    constructor() {}
}
