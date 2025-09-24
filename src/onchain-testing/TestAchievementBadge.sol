// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title TestAchievementBadge
/// @notice A test-only contract for experimenting with unrestricted badge minting and transfers
contract TestAchievementBadge is ERC721, ERC721URIStorage {
    uint256 private _tokenIds;

    struct BadgeMetadata {
        string name;
        string description;
        uint256 achievementId;
        uint256 earnedTimestamp;
        uint8 rarity; // 1=Common, 2=Rare, 3=Epic, 4=Legendary, 5=Mythic, 6=Exclusive, 7=Unique, 8=Godlike, 9=Immortal
        bool soulbound;
    }

    mapping(uint256 => BadgeMetadata) public badgeMetadata;
    mapping(address => uint256[]) public userBadges;
    mapping(address => mapping(uint256 => bool)) public hasEarnedAchievement;

    event BadgeMinted(address indexed to, uint256 indexed tokenId, uint256 indexed achievementId);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _tokenIds = 0;
        string memory info = "Test 4";
    }

    /// @notice Anyone can mint a badge (no restrictions)
    function mintBadge(
        address to,
        uint256 achievementId,
        string memory name,
        string memory description,
        uint8 rarity,
        bool soulbound,
        string memory tokenURI_
    ) external returns (uint256) {
        require(rarity >= 1 && rarity <= 9, "invalid rarity");

        _tokenIds++;
        uint256 tokenId = _tokenIds;

        _safeMint(to, tokenId);
        if (bytes(tokenURI_).length > 0) {
            _setTokenURI(tokenId, tokenURI_);
        }

        badgeMetadata[tokenId] = BadgeMetadata({
            name: name,
            description: description,
            achievementId: achievementId,
            earnedTimestamp: block.timestamp,
            rarity: rarity,
            soulbound: soulbound
        });

        userBadges[to].push(tokenId);
        hasEarnedAchievement[to][achievementId] = true;

        emit BadgeMinted(to, tokenId, achievementId);
        return tokenId;
    }

    function getUserBadges(address user) external view returns (uint256[] memory) {
        return userBadges[user];
    }

    function getUserBadgeCount(address user) external view returns (uint256) {
        return userBadges[user].length;
    }

    function hasUserEarnedAchievement(address user, uint256 achievementId) external view returns (bool) {
        return hasEarnedAchievement[user][achievementId];
    }

    /// @notice Transfer logic (soulbound enforcement still respected)
    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        require(!badgeMetadata[tokenId].soulbound, "token is soulbound");
        super.transferFrom(from, to, tokenId);
        _removeFromUserBadges(from, tokenId);
        userBadges[to].push(tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override(ERC721, IERC721)
    {
        require(!badgeMetadata[tokenId].soulbound, "token is soulbound");
        super.safeTransferFrom(from, to, tokenId, data);
        _removeFromUserBadges(from, tokenId);
        userBadges[to].push(tokenId);
    }

    function _removeFromUserBadges(address user, uint256 tokenId) private {
        uint256[] storage badges = userBadges[user];
        for (uint256 i = 0; i < badges.length; i++) {
            if (badges[i] == tokenId) {
                badges[i] = badges[badges.length - 1];
                badges.pop();
                break;
            }
        }
    }

    // Overrides
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
