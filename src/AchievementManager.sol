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

}
