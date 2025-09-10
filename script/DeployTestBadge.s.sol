// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/onchain-testing/TestAchievementBadge.sol";

/// @notice Foundry script to deploy TestAchievementBadge
contract DeployTestBadge is Script {
    function run() external {
        // Load deployer private key from environment (PRIVATE_KEY)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        TestAchievementBadge badge = new TestAchievementBadge(
            "Test Achievement Badges", // Token name
            "TESTBADGE"                // Token symbol
        );

        vm.stopBroadcast();

        console.log("Deployed TestAchievementBadge at:", address(badge));
    }
}
