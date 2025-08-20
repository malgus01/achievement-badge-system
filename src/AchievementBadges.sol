// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AchievementBadges is ERC1155, AccessControl, ReentrancyGuard {
    using Strings for uint256;
    using Counters for Counters.Counter;

    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // State variables
    Counters.Counter private _badgeIdCounter;
    string public name = "Achievement Badges";
    string public symbol = "BADGE";

    // Badge metadata
    struct BadgeInfo {
        string name;
        string description;
        string imageUri;
        uint8 rarity; // 1-5 scale
        bool soulbound;
        bool exists;
        uint256 totalSupply;
        uint256 maxSupply;
    }

    mapping(uint256 => BadgeInfo) public badges;
    mapping(uint256 => mapping(address => bool)) public hasBadge;
    mapping(address => uint256[]) public userBadges;

    // Events
    event BadgeCreated(uint256 indexed badgeId, string name, uint8 rarity, bool soulbound);
    event BadgeMinted(address indexed to, uint256 indexed badgeId, uint256 amount);
}
