// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title RWAFactory
 * @dev Factory contract for creating RWA tokens and vaults
 * 
 * Features:
 * - CREATE pattern: Dynamic contract creation
 * - CREATE2 pattern: Deterministic contract addresses
 * - Event emission for indexing
 * - Consistent initialization
 * 
 * Design Pattern:
 * - Factory: Centralized deployment with deterministic addresses
 */

import "../tokens/RWAToken.sol";

contract RWAFactory {
    // ============ State ============
    address[] public createdTokens;
    mapping(address => bool) public isCreatedToken;

    // ============ Events ============
    event TokenCreated(
        address indexed tokenAddress,
        string name,
        string symbol,
        address indexed creator
    );

    event TokenCreatedDeterministic(
        address indexed tokenAddress,
        string name,
        string symbol,
        bytes32 salt
    );

    // ============ CREATE Pattern ============
    /**
     * @notice Create new RWA token using CREATE opcode
     * @param name Token name
     * @param symbol Token symbol
     * @param initialSupply Initial supply
     * @param admin Admin address
     * @return newToken Address of created token
     */
    function createRWAToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address admin
    ) external returns (address newToken) {
        require(admin != address(0), "Invalid admin");

        newToken = address(
            new RWAToken(name, symbol, initialSupply, admin)
        );

        createdTokens.push(newToken);
        isCreatedToken[newToken] = true;

        emit TokenCreated(newToken, name, symbol, msg.sender);
    }

    // ============ CREATE2 Pattern ============
    /**
     * @notice Create new RWA token using CREATE2 (deterministic address)
     * @param name Token name
     * @param symbol Token symbol
     * @param salt Salt for deterministic address
     * @param admin Admin address
     * @return newToken Address of created token
     */
    function createRWATokenDeterministic(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address admin
    ) external returns (address newToken) {
        require(admin != address(0), "Invalid admin");

        newToken = address(
            new RWAToken{salt: salt}(name, symbol, 0, admin)
        );

        createdTokens.push(newToken);
        isCreatedToken[newToken] = true;

        // Grant minter role to creator
        RWAToken(newToken).grantRole(
            keccak256("MINTER_ROLE"),
            msg.sender
        );

        emit TokenCreatedDeterministic(newToken, name, symbol, salt);
    }

    // ============ View Functions ============
    /**
     * @notice Get number of created tokens
     * @return Count of created tokens
     */
    function getCreatedTokensCount() external view returns (uint256) {
        return createdTokens.length;
    }

    /**
     * @notice Get paginated list of created tokens
     * @param offset Starting index
     * @param limit Number of tokens to return
     * @return Array of token addresses
     */
    function getCreatedTokens(uint256 offset, uint256 limit)
        external
        view
        returns (address[] memory)
    {
        require(offset < createdTokens.length, "Invalid offset");

        uint256 end = offset + limit > createdTokens.length
            ? createdTokens.length
            : offset + limit;

        address[] memory tokens = new address[](end - offset);

        for (uint256 i = offset; i < end; i++) {
            tokens[i - offset] = createdTokens[i];
        }

        return tokens;
    }

    /**
     * @notice Calculate deterministic address for given salt
     * @param name Token name
     * @param symbol Token symbol
     * @param salt Salt value
     * @param admin Admin address
     * @return predictedAddress Predicted address
     */
    function predictAddress(
        string memory name,
        string memory symbol,
        bytes32 salt,
        address admin
    ) external view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(RWAToken).creationCode,
            abi.encode(name, symbol, 0, admin)
        );

        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode))
        );

        return address(uint160(uint256(hash)));
    }
}
