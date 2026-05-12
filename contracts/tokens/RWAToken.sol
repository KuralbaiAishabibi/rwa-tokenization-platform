// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title RWAToken
 * @dev ERC-20 asset-backed token with role-based minting control
 * 
 * Features:
 * - ERC20 standard compliance
 * - Role-based access control (MINTER, PAUSER)
 * - Pausable functionality for emergency stops
 * - No unguarded admin functions
 * 
 * Design Patterns:
 * - Access Control: Role-based permissions
 * - Pausable: Circuit breaker for emergency
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract RWAToken is ERC20, ERC20Burnable, Pausable, AccessControl, ERC20Permit {
    // ============ Role Definitions ============
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // ============ Events ============
    event TokenMinted(address indexed to, uint256 amount);
    event TokenBurned(address indexed from, uint256 amount);

    // ============ Constructor ============
    /**
     * @param _name Token name
     * @param _symbol Token symbol
     * @param initialSupply Initial token supply (optional)
     * @param admin Initial admin address
     */
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 initialSupply,
        address admin
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        require(admin != address(0), "Invalid admin");

        // Grant roles to admin
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);

        // Mint initial supply if provided
        if (initialSupply > 0) {
            _mint(admin, initialSupply);
        }
    }

    // ============ Minting ============
    /**
     * @notice Mint tokens (only MINTER_ROLE)
     * @param to Recipient address
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Cannot mint zero");
        
        _mint(to, amount);
        emit TokenMinted(to, amount);
    }

    // ============ Pausing ============
    /**
     * @notice Pause token transfers (only PAUSER_ROLE)
     */
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /**
     * @notice Unpause token transfers (only DEFAULT_ADMIN_ROLE)
     */
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // ============ Internal Overrides ============
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override {
        super._update(from, to, amount);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public override(ERC20Permit) {
        super.permit(owner, spender, value, deadline, v, r, s);
    }

    // ============ Burn Override ============
    function burn(uint256 amount) public override {
        super.burn(amount);
        emit TokenBurned(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public override {
        super.burnFrom(account, amount);
        emit TokenBurned(account, amount);
    }
}
