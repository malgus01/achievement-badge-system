
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interface/IActivityTracker.sol";

/**
 * @title DeFiActivityTracker
 * @dev Tracks DeFi-related activities like swaps, liquidity provision, lending, etc.
 */
contract DeFiActivityTracker is IActivityTracker, Ownable, ReentrancyGuard {

    constructor(address initialOwner) Ownable(initialOwner) {}

}

