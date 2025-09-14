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
}
