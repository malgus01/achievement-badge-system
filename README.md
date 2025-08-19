# Achievement Badges System

A comprehensive Solidity-based achievement system that allows users to earn NFT badges through various on-chain activities. The system is designed to be modular, gas-efficient, and extensible for different types of blockchain interactions.

## Architecture

```
┌─────────────────────┐    ┌──────────────────────┐    ┌─────────────────────┐
│   Activity Trackers │───▶│  AchievementManager  │───▶│  AchievementBadge   │
│  (DeFi, Governance) │    │   (Central Logic)    │    │    (NFT Contract)   │
└─────────────────────┘    └──────────────────────┘    └─────────────────────┘
            │                           │                           │
            │                           │                           │
            ▼                           ▼                           ▼
    ┌───────────────┐         ┌──────────────────┐         ┌───────────────┐
    │   Off-chain   │         │   Achievement    │         │   Badge       │
    │   Services    │         │   Definitions    │         │   Metadata    │
    │ (Indexers,    │         │   & Progress     │         │   & Images    │
    │  Oracles)     │         │   Tracking       │         │   (IPFS)      │
    └───────────────┘         └──────────────────┘         └───────────────┘
```

## Core Contracts

### 1. AchievementBadge.sol

The main NFT contract that handles badge minting and management.

**Key Features:**
- ERC721-compliant with metadata extension
- Soul-bound (non-transferable) badge support
- Rarity system (Common, Rare, Epic, Legendary)
- User badge tracking and enumeration
- Prevention of duplicate achievement badges

**Key Functions:**
```solidity
function mintBadge(
    address to,
    uint256 achievementId,
    string memory name,
    string memory description,
    uint8 rarity,
    bool soulbound
) external returns (uint256)
function getUserBadges(address user) external view returns (uint256[] memory)
