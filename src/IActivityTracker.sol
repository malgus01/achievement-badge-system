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
    
}
