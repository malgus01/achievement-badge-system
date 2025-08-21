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

    event TokenURIUpdated(uint256 indexed achievementId, string newURI);

   modifier onlyAchievementManager() {
        require(msg.sender == achievementManager, "AchievementBadge: caller is not the achievement manager");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        address initialOwner
    ) ERC721(name, symbol) Ownable(initialOwner) {
        // Start token IDs at 1
        _tokenIdCounter.increment();
    }
}
