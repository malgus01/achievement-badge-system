// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./AchievementBadge.sol";
import "./IActivityTracker.sol";

/**
 * @title AchievementManager
 * @dev Central manager for all achievements and badge minting
 * @author MLGHECTIIK
 */
contract AchievementManager is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    Counters.Counter private _achievementIdCounter;

    // Achievement types
    enum AchievementType {
        ACTIVITY_COUNT,     // Complete X activities
        VALUE_THRESHOLD,    // Reach X value in activities
        STREAK,            // Complete activities X days in a row
        COMBO,             // Complete multiple different activities
        TIME_BASED         // Complete activity within timeframe
    }

    // Achievement structure
    struct Achievement {
        uint256 id;
        string name;
        string description;
        AchievementType achievementType;
        address[] requiredTrackers;     // Activity tracker contracts to check
        uint256[] thresholds;          // Required values for completion
        uint256 timeLimit;             // Time limit in seconds (0 = no limit)
        uint8 rarity;                  // 1=Common, 2=Rare, 3=Epic, 4=Legendary
        bool isActive;                 // Whether achievement can be earned
        bool soulbound;                // Whether resulting badge is soul-bound
        uint256 maxEarners;            // Max users who can earn (0 = unlimited)
        uint256 currentEarners;        // Current number of users who earned it
    }

    // Reference to the badge contract
    AchievementBadge public badgeContract;

    // Mapping from achievement ID to achievement data
    mapping(uint256 => Achievement) public achievements;


}
