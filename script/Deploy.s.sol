// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "../contracts/tokens/RWAToken.sol";
import "../contracts/tokens/GovernanceToken.sol";
import "../contracts/core/RWAFactory.sol";

/**
 * @title Deploy Script
 * @notice Deployment script for RWA Tokenization Platform
 * 
 * Usage:
 * 1. Set environment variables:
 *    - PRIVATE_KEY: Your private key
 *    - ARBISCAN_API_KEY: For verification (optional)
 * 
 * 2. Deploy to testnet:
 *    forge script script/Deploy.s.sol --rpc-url arbitrum_sepolia --broadcast --verify
 * 
 * 3. Verify after deployment:
 *    forge verify-contract --chain-id 421614 <ADDRESS> RWAToken
 */

contract Deploy is Script {
    // ============ Deployment Parameters ============
    string constant RWA_TOKEN_NAME = "RWA Token";
    string constant RWA_TOKEN_SYMBOL = "RWA";
    uint256 constant RWA_INITIAL_SUPPLY = 1_000_000 ether;

    string constant GOV_TOKEN_NAME = "RWA Governance Token";
    string constant GOV_TOKEN_SYMBOL = "GOV";
    uint256 constant GOV_INITIAL_SUPPLY = 100_000 ether;
    uint256 constant GOV_MAX_SUPPLY = 10_000_000 ether;

    // ============ State ============
    address public admin;
    RWAToken public rwaToken;
    GovernanceToken public govToken;
    RWAFactory public factory;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        admin = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts...");
        console.log("Admin:", admin);
        console.log("Network:", block.chainid);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy RWA Token
        console.log("\n1. Deploying RWAToken...");
        rwaToken = new RWAToken(
            RWA_TOKEN_NAME,
            RWA_TOKEN_SYMBOL,
            RWA_INITIAL_SUPPLY,
            admin
        );
        console.log("RWAToken deployed at:", address(rwaToken));

        // Deploy Governance Token
        console.log("\n2. Deploying GovernanceToken...");
        govToken = new GovernanceToken(GOV_INITIAL_SUPPLY, GOV_MAX_SUPPLY);
        console.log("GovernanceToken deployed at:", address(govToken));

        // Deploy Factory
        console.log("\n3. Deploying RWAFactory...");
        factory = new RWAFactory();
        console.log("RWAFactory deployed at:", address(factory));

        vm.stopBroadcast();

        // Print summary
        console.log("\n============ Deployment Summary ============");
        console.log("RWAToken:", address(rwaToken));
        console.log("GovernanceToken:", address(govToken));
        console.log("RWAFactory:", address(factory));
        console.log("===========================================");

        // Verification commands
        console.log("\n============ Verification Commands ============");
        console.log("RWAToken:");
        console.log(
            "forge verify-contract --chain-id %d %s RWAToken",
            block.chainid,
            address(rwaToken)
        );
        console.log("GovernanceToken:");
        console.log(
            "forge verify-contract --chain-id %d %s GovernanceToken",
            block.chainid,
            address(govToken)
        );
        console.log("RWAFactory:");
        console.log(
            "forge verify-contract --chain-id %d %s RWAFactory",
            block.chainid,
            address(factory)
        );
    }
}

/**
 * @title Post-Deployment Verification Script
 * @notice Verify deployment was successful
 */
contract VerifyDeployment is Script {
    function run() public view {
        console.log("Post-Deployment Verification");
        console.log("=============================");

        // These checks should be performed on deployed contracts
        console.log("1. Check admin roles assigned");
        console.log("2. Check token balances");
        console.log("3. Check total supplies");
        console.log("4. Verify contract sources on explorer");
    }
}
