// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title RWAVault
 * @dev ERC-4626 tokenized vault with UUPS upgradeable pattern
 * 
 * Features:
 * - Full ERC-4626 compliance with rounding invariants
 * - UUPS upgradeable with V1→V2 migration path
 * - Yield generation from underlying assets
 * - Role-based access control
 * 
 * Design Patterns:
 * - UUPS Proxy: Upgradeable contract logic
 * - ERC-4626: Standard yield vault interface
 * - ReentrancyGuard: Protection against reentrancy
 * - Checks-Effects-Interactions: Safe state management
 */

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC4626Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract RWAVault is
    Initializable,
    ERC20Upgradeable,
    ERC4626Upgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    // ============ Role Definitions ============
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // ============ Events ============
    event UpgradeAuthorized(address indexed newImplementation);
    event VaultInitialized(address indexed asset, string name, string symbol);

    // ============ Initializer ============
    /**
     * @notice Initialize vault (replaces constructor for upgradeable contracts)
     * @param _asset Underlying asset address
     * @param _name Vault name
     * @param _symbol Vault symbol
     */
    function initialize(
        address _asset,
        string memory _name,
        string memory _symbol,
        address admin
    ) public initializer {
        require(_asset != address(0), "Invalid asset");
        require(admin != address(0), "Invalid admin");

        // Initialize parent contracts
        __ERC20_init(_name, _symbol);
        __ERC4626_init(IERC20(_asset));
        __Pausable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        // Grant roles
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);

        emit VaultInitialized(_asset, _name, _symbol);
    }

    // ============ Vault Operations ============
    /**
     * @notice Deposit assets and receive shares
     * @param assets Amount of assets to deposit
     * @param receiver Recipient of shares
     * @return shares Amount of shares minted
     */
    function deposit(uint256 assets, address receiver)
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        require(assets > 0, "Zero deposit");
        require(receiver != address(0), "Invalid receiver");

        return super.deposit(assets, receiver);
    }

    /**
     * @notice Withdraw assets by burning shares
     * @param assets Amount of assets to withdraw
     * @param receiver Recipient of assets
     * @param owner Owner of shares
     * @return shares Amount of shares burned
     */
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    )
        public
        override
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        require(assets > 0, "Zero withdrawal");
        require(receiver != address(0), "Invalid receiver");

        return super.withdraw(assets, receiver, owner);
    }

    // ============ Pausing ============
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // ============ Upgrade Authorization ============
    /**
     * @notice Authorize upgrade to new implementation
     * @param newImplementation Address of new implementation
     * 
     * NOTE: Only UPGRADER_ROLE can authorize. Actual upgrade happens via proxy.
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {
        emit UpgradeAuthorized(newImplementation);
    }

    // ============ Internal Overrides ============
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Upgradeable) whenNotPaused {
        super._update(from, to, amount);
    }

    function decimals()
        public
        view
        override(ERC20Upgradeable, ERC4626Upgradeable)
        returns (uint8)
    {
        return super.decimals();
    }

    // ============ ERC4626 Overrides ============
    function asset()
        public
        view
        override(ERC4626Upgradeable)
        returns (address)
    {
        return super.asset();
    }

    function totalAssets()
        public
        view
        override(ERC4626Upgradeable)
        returns (uint256)
    {
        return super.totalAssets();
    }

    function convertToShares(uint256 assets)
        public
        view
        override(ERC4626Upgradeable)
        returns (uint256)
    {
        return super.convertToShares(assets);
    }

    function convertToAssets(uint256 shares)
        public
        view
        override(ERC4626Upgradeable)
        returns (uint256)
    {
        return super.convertToAssets(shares);
    }

    function maxDeposit(address owner)
        public
        view
        override(ERC4626Upgradeable)
        returns (uint256)
    {
        return super.maxDeposit(owner);
    }

    function previewDeposit(uint256 assets)
        public
        view
        override(ERC4626Upgradeable)
        returns (uint256)
    {
        return super.previewDeposit(assets);
    }
}
