// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IActivityTracker
 * @dev Interface for activity tracking contracts
 * @author Your Name
 */
interface IActivityTracker {
    // Events
    event ActivityRecorded(address indexed user, bytes32 indexed activityType, uint256 value, uint256 timestamp);
    event UserStatsUpdated(address indexed user, bytes32 indexed statType, uint256 oldValue, uint256 newValue);

    /**
     * @dev Record a new activity for a user
     * @param user Address of the user
     * @param activityType Type of activity (hashed string)
     * @param value Value associated with the activity
     */
    function recordActivity(address user, bytes32 activityType, uint256 value) external;

    /**
     * @dev Get user's total count for a specific activity type
     * @param user User address
     * @param activityType Type of activity
     * @return Total count of activities
     */
    function getUserActivityCount(address user, bytes32 activityType) external view returns (uint256);

    /**
     * @dev Get user's total value for a specific activity type
     * @param user User address
     * @param activityType Type of activity
     * @return Total value of activities
     */
    function getUserActivityValue(address user, bytes32 activityType) external view returns (uint256);

    /**
     * @dev Get user's current streak for a specific activity type
     * @param user User address
     * @param activityType Type of activity
     * @return Current streak count
     */
    function getUserStreak(address user, bytes32 activityType) external view returns (uint256);

    /**
     * @dev Get user's last activity timestamp for a specific type
     * @param user User address
     * @param activityType Type of activity
     * @return Timestamp of last activity
     */
    function getLastActivityTimestamp(address user, bytes32 activityType) external view returns (uint256);

    /**
     * @dev Check if user has been active in the last X seconds
     * @param user User address
     * @param activityType Type of activity
     * @param timeWindow Time window in seconds
     * @return True if user was active within timeframe
     */
    function isUserActiveWithin(address user, bytes32 activityType, uint256 timeWindow) external view returns (bool);

    function getUserStats(address user, bytes32 activityType) 
        external 
        view 
        returns (uint256 count, uint256 value, uint256 streak, uint256 lastTimestamp);
}
