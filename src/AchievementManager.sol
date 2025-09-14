// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./AchievementBadges.sol";
import "./IActivityTracker.sol";

/**
 * @title AchievementManager
 * @dev Central manager for all achievements and badge minting
 * @author MLGHECTIIK
 */
contract AchievementManager is Ownable, ReentrancyGuard {
    uint256 private _achievementIdCounter;

    // Achievement types
    enum AchievementType {
        ACTIVITY_COUNT, // Complete X activities
        VALUE_THRESHOLD, // Reach X value in activities
        STREAK, // Complete activities X days in a row
        COMBO, // Complete multiple different activities
        TIME_BASED // Complete activity within timeframe

    }

    // Achievement structure
    struct Achievement {
        uint256 id;
        string name;
        string description;
        AchievementType achievementType;
        address[] requiredTrackers; // Activity tracker contracts to check
        uint256[] thresholds; // Required values for completion
        uint256 timeLimit; // Time limit in seconds (0 = no limit)
        uint8 rarity; // 1=Common, 2=Rare, 3=Epic, 4=Legendary
        bool isActive; // Whether achievement can be earned
        bool soulbound; // Whether resulting badge is soul-bound
        uint256 maxEarners; // Max users who can earn (0 = unlimited)
        uint256 currentEarners; // Current number of users who earned it
    }

    // Reference to the badge contract
    AchievementBadge public badgeContract;

    // Mapping from achievement ID to achievement data
    mapping(uint256 => Achievement) public achievements;

    // Mapping from user to achievement ID to progress
    mapping(address => mapping(uint256 => uint256)) public userProgress;

    // Mapping from user to achievement ID to completion timestamp
    mapping(address => mapping(uint256 => uint256)) public userCompletionTime;

    // Mapping to track authorized activity trackers
    mapping(address => bool) public authorizedTrackers;

    // Array of all achievement IDs
    uint256[] public allAchievementIds;

    // Events
    event AchievementCreated(uint256 indexed achievementId, string name, AchievementType achievementType);
    event AchievementUpdated(uint256 indexed achievementId);
    event ProgressUpdated(address indexed user, uint256 indexed achievementId, uint256 progress);
    event AchievementCompleted(address indexed user, uint256 indexed achievementId, uint256 badgeTokenId);
    event TrackerAuthorized(address indexed tracker, bool authorized);
    event BadgeContractUpdated(address indexed oldContract, address indexed newContract);

    modifier onlyAuthorizedTracker() {
        require(authorizedTrackers[msg.sender], "AchievementManager: caller is not authorized tracker");
        _;
    }

    constructor(address initialOwner) Ownable(initialOwner) {
        // Start achievement IDs at 1
        _achievementIdCounter = 1;
    }

    /**
     * @dev Set the badge contract address
     * @param _badgeContract Address of the AchievementBadge contract
     */
    function setBadgeContract(address _badgeContract) external onlyOwner {
        address oldContract = address(badgeContract);
        badgeContract = AchievementBadge(_badgeContract);
        emit BadgeContractUpdated(oldContract, _badgeContract);
    }

    /**
     * @dev Authorize or deauthorize an activity tracker
     * @param tracker Address of the activity tracker
     * @param authorized Whether to authorize or deauthorize
     */
    function setTrackerAuthorization(address tracker, bool authorized) external onlyOwner {
        authorizedTrackers[tracker] = authorized;
        emit TrackerAuthorized(tracker, authorized);
    }

    /**
     * @dev Create a new achievement
     * @param name Name of the achievement
     * @param description Description of the achievement
     * @param achievementType Type of achievement
     * @param requiredTrackers Array of tracker addresses to check
     * @param thresholds Array of threshold values required
     * @param timeLimit Time limit in seconds (0 for no limit)
     * @param rarity Rarity level (1-4)
     * @param soulbound Whether the badge should be soul-bound
     * @param maxEarners Maximum number of users who can earn (0 for unlimited)
     */
    function createAchievement(
        string memory name,
        string memory description,
        AchievementType achievementType,
        address[] memory requiredTrackers,
        uint256[] memory thresholds,
        uint256 timeLimit,
        uint8 rarity,
        bool soulbound,
        uint256 maxEarners
    ) external onlyOwner returns (uint256) {
        require(bytes(name).length > 0, "AchievementManager: name cannot be empty");
        require(rarity >= 1 && rarity <= 4, "AchievementManager: invalid rarity");
        require(requiredTrackers.length > 0, "AchievementManager: must have at least one tracker");

        // Validate all trackers are authorized
        for (uint256 i = 0; i < requiredTrackers.length; i++) {
            require(authorizedTrackers[requiredTrackers[i]], "AchievementManager: tracker not authorized");
        }

        _achievementIdCounter++;
        uint256 achievementId = _achievementIdCounter;

        achievements[achievementId] = Achievement({
            id: achievementId,
            name: name,
            description: description,
            achievementType: achievementType,
            requiredTrackers: requiredTrackers,
            thresholds: thresholds,
            timeLimit: timeLimit,
            rarity: rarity,
            isActive: true,
            soulbound: soulbound,
            maxEarners: maxEarners,
            currentEarners: 0
        });

        allAchievementIds.push(achievementId);

        emit AchievementCreated(achievementId, name, achievementType);
        return achievementId;
    }

    /**
     * @dev Update user progress for an achievement (called by activity trackers)
     * @param user User address
     * @param achievementId Achievement ID
     * @param progress New progress value
     */
    function updateProgress(address user, uint256 achievementId, uint256 progress) external onlyAuthorizedTracker {
        require(achievements[achievementId].isActive, "AchievementManager: achievement not active");
        require(!badgeContract.hasUserEarnedAchievement(user, achievementId), "AchievementManager: already earned");

        userProgress[user][achievementId] = progress;
        emit ProgressUpdated(user, achievementId, progress);

        // Check if achievement is completed
        if (_checkAchievementCompletion(user, achievementId)) {
            _completeAchievement(user, achievementId);
        }
    }

    /**
     * @dev Manually check and complete achievement for a user (gas-optimized batch operation)
     * @param user User address
     * @param achievementId Achievement ID
     */
    function checkAndCompleteAchievement(address user, uint256 achievementId) external nonReentrant {
        require(achievements[achievementId].isActive, "AchievementManager: achievement not active");
        require(!badgeContract.hasUserEarnedAchievement(user, achievementId), "AchievementManager: already earned");

        if (_checkAchievementCompletion(user, achievementId)) {
            _completeAchievement(user, achievementId);
        }
    }

    /**
     * @dev Batch check multiple achievements for a user
     * @param user User address
     * @param achievementIds Array of achievement IDs to check
     */
    function batchCheckAchievements(address user, uint256[] calldata achievementIds) external nonReentrant {
        for (uint256 i = 0; i < achievementIds.length; i++) {
            uint256 achievementId = achievementIds[i];

            if (!achievements[achievementId].isActive) continue;
            if (badgeContract.hasUserEarnedAchievement(user, achievementId)) continue;

            if (_checkAchievementCompletion(user, achievementId)) {
                _completeAchievement(user, achievementId);
            }
        }
    }

    /**
     * @dev Check if user has completed an achievement
     * @param user User address
     * @param achievementId Achievement ID
     * @return True if achievement is completed
     */
    function _checkAchievementCompletion(address user, uint256 achievementId) private view returns (bool) {
        Achievement memory achievement = achievements[achievementId];

        // Check if max earners limit reached
        if (achievement.maxEarners > 0 && achievement.currentEarners >= achievement.maxEarners) {
            return false;
        }

        // Check time limit
        if (achievement.timeLimit > 0) {
            uint256 startTime = userCompletionTime[user][achievementId];
            if (startTime == 0) startTime = block.timestamp;
            if (block.timestamp > startTime + achievement.timeLimit) {
                return false;
            }
        }

        // Check progress against thresholds based on achievement type
        if (
            achievement.achievementType == AchievementType.ACTIVITY_COUNT
                || achievement.achievementType == AchievementType.VALUE_THRESHOLD
                || achievement.achievementType == AchievementType.STREAK
        ) {
            // For these types, check if progress meets the first threshold
            if (achievement.thresholds.length > 0) {
                return userProgress[user][achievementId] >= achievement.thresholds[0];
            }
        }

        // For COMBO and TIME_BASED, implement custom logic
        // This can be extended based on specific requirements

        return false;
    }

    /**
     * @dev Complete achievement and mint badge
     * @param user User address
     * @param achievementId Achievement ID
     */
    function _completeAchievement(address user, uint256 achievementId) private {
        Achievement storage achievement = achievements[achievementId];

        // Mint badge
        uint256 tokenId = badgeContract.mintBadge(
            user, achievementId, achievement.name, achievement.description, achievement.rarity, achievement.soulbound
        );

        // Update completion tracking
        userCompletionTime[user][achievementId] = block.timestamp;
        achievement.currentEarners++;

        emit AchievementCompleted(user, achievementId, tokenId);
    }

    /**
     * @dev Get all achievement IDs
     * @return Array of all achievement IDs
     */
    function getAllAchievementIds() external view returns (uint256[] memory) {
        return allAchievementIds;
    }

    /**
     * @dev Get achievement details
     * @param achievementId Achievement ID
     * @return Achievement struct
     */
    function getAchievement(uint256 achievementId) external view returns (Achievement memory) {
        return achievements[achievementId];
    }
}
