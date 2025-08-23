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

    /**
     * @dev Set the achievement manager contract address
     * @param _achievementManager Address of the AchievementManager contract
     */
    function setAchievementManager(address _achievementManager) external onlyOwner {
        address oldManager = achievementManager;
        achievementManager = _achievementManager;
        emit AchievementManagerUpdated(oldManager, _achievementManager);
    }

    /**
     * @dev Set token URI for a specific achievement ID
     * @param achievementId The achievement ID
     * @param tokenURI The metadata URI
     */
    function setAchievementTokenURI(uint256 achievementId, string memory tokenURI) external onlyOwner {
        achievementTokenURIs[achievementId] = tokenURI;
        emit TokenURIUpdated(achievementId, tokenURI);
    }

    /**
     * @dev Mint a badge to a user (only callable by AchievementManager)
     * @param to Address to mint the badge to
     * @param achievementId The achievement ID this badge represents
     * @param name Name of the badge
     * @param description Description of the badge
     * @param rarity Rarity level (1-4)
     * @param soulbound Whether the badge is soul-bound (non-transferable)
     */
    function mintBadge(
        address to,
        uint256 achievementId,
        string memory name,
        string memory description,
        uint8 rarity,
        bool soulbound
    ) external onlyAchievementManager returns (uint256) {
        require(to != address(0), "AchievementBadge: mint to zero address");
        require(!hasEarnedAchievement[to][achievementId], "AchievementBadge: achievement already earned");
        require(rarity >= 1 && rarity <= 4, "AchievementBadge: invalid rarity");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        // Mint the token
        _safeMint(to, tokenId);

        // Set token URI if available
        string memory tokenURI = achievementTokenURIs[achievementId];
        if (bytes(tokenURI).length > 0) {
            _setTokenURI(tokenId, tokenURI);
        }

        // Store badge metadata
        badgeMetadata[tokenId] = BadgeMetadata({
            name: name,
            description: description,
            achievementId: achievementId,
            earnedTimestamp: block.timestamp,
            rarity: rarity,
            soulbound: soulbound
        });

        // Update user's badge list
        userBadges[to].push(tokenId);
        hasEarnedAchievement[to][achievementId] = true;

        emit BadgeMinted(to, tokenId, achievementId);
        return tokenId;
    }

    /**
     * @dev Get all badge token IDs owned by a user
     * @param user User address
     * @return Array of token IDs
     */
    function getUserBadges(address user) external view returns (uint256[] memory) {
        return userBadges[user];
    }

    /**
     * @dev Get badge count for a user
     * @param user User address
     * @return Number of badges owned
     */
    function getUserBadgeCount(address user) external view returns (uint256) {
        return userBadges[user].length;
    }

    /**
     * @dev Check if user has earned a specific achievement
     * @param user User address
     * @param achievementId Achievement ID
     * @return True if user has earned the achievement
     */
    function hasUserEarnedAchievement(address user, uint256 achievementId) external view returns (bool) {
        return hasEarnedAchievement[user][achievementId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(!badgeMetadata[tokenId].soulbound, "AchievementBadge: token is soul-bound");
        super.transferFrom(from, to, tokenId);
        
        // Update user badge arrays
        _removeFromUserBadges(from, tokenId);
        userBadges[to].push(tokenId);
    }
}
