// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AchievementBadge is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Badge metadata structure
    struct BadgeMetadata {
        string name;
        string description;
        uint256 achievementId;
        uint256 earnedTimestamp;
        uint8 rarity; // 1=Common, 2=Rare, 3=Epic, 4=Legendary
        bool soulbound;
    }

    // Mapping from token ID to badge metadata
    mapping(uint256 => BadgeMetadata) public badgeMetadata;

    // Mapping from user address to list of their badge token IDs
    mapping(address => uint256[]) public userBadges;

    // Mapping from achievement ID to badge token URI
    mapping(uint256 => string) public achievementTokenURIs;

    // Mapping to track if user has earned specific achievement
    mapping(address => mapping(uint256 => bool)) public hasEarnedAchievement;

    // Address of the AchievementManager contract (only this can mint badges)
    address public achievementManager;

    // Events
    event BadgeMinted(address indexed to, uint256 indexed tokenId, uint256 indexed achievementId);

    event AchievementManagerUpdated(address indexed oldManager, address indexed newManager);

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
