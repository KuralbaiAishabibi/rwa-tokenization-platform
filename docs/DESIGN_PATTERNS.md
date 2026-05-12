# Design Patterns Documentation

## Overview

This document describes the design patterns used in the RWA Tokenization Platform and their justifications.

---

## 1. UUPS Proxy Pattern (Upgradeable Contracts)

**Location**: `contracts/proxies/`, `RWAVault.sol`

**Pattern Structure**:
```
User ─→ Proxy (UUPSProxy.sol) ─→ Implementation (RWAVaultV1.sol)
                                     ↓
                              Implementation (RWAVaultV2.sol) [After upgrade]
```

**Why This Pattern?**
- Upgrade logic lives in implementation (not proxy)
- No admin function selector clash with implementation
- Smaller proxy bytecode
- Better gas efficiency

**Implementation Example**:
```solidity
contract RWAVault is ERC4626, UUPSUpgradeable, AccessControl {
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}
}
```

**V1 → V2 Upgrade Path**:
1. Deploy RWAVaultV2
2. Call Governor to propose upgrade
3. Vote on upgrade proposal
4. Queue in Timelock (2-day delay)
5. Execute upgrade (only admin can call)
6. Verify: `upgradeTo(address newImplementation)`

**Security Considerations**:
- Storage layout must be compatible
- New variables append to end only
- Old variables never removed
- V1 storage layout documented and frozen

---

## 2. Factory Pattern (Contract Deployment)

**Location**: `contracts/core/RWAFactory.sol`

**Purpose**: Enable efficient creation of RWA tokens and vaults with consistent configuration.

**Implementation**:
```solidity
contract RWAFactory {
    address[] public createdTokens;
    
    function createRWAToken(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        address admin
    ) external returns (address newToken) {
        newToken = address(new RWAToken(name, symbol, initialSupply, admin));
        createdTokens.push(newToken);
        emit TokenCreated(newToken, msg.sender);
    }
    
    // CREATE2 for deterministic addresses
    function createRWATokenDeterministic(
        string memory name,
        string memory symbol,
        bytes32 salt
    ) external returns (address newToken) {
        newToken = address(new RWAToken{salt: salt}(name, symbol, 0, msg.sender));
        emit TokenCreated(newToken, msg.sender);
    }
}
```

**Benefits**:
- Consistent initialization
- Event emission for indexing
- Deterministic addresses (CREATE2)
- Single source of truth for deployed contracts

**Trade-offs**:
- Centralized factory deployment authority
- Mitigated by: DAO governance over factory parameters

---

## 3. Checks-Effects-Interactions (CEI) Pattern

**Location**: All state-changing functions

**Pattern**:
```
1. CHECKS   ─→ Validate inputs & preconditions
2. EFFECTS  ─→ Modify state
3. INTERACTIONS ─→ External calls last
```

**Example (deposit function)**:
```solidity
function deposit(uint256 assets, address receiver)
    public
    returns (uint256 shares)
{
    // 1. CHECKS
    require(assets > 0, "Zero deposit");
    require(receiver != address(0), "Invalid receiver");
    
    // 2. EFFECTS
    uint256 shares = convertToShares(assets);
    _mint(receiver, shares);
    totalAssets += assets;
    
    // 3. INTERACTIONS (external call LAST)
    asset.safeTransferFrom(msg.sender, address(this), assets);
    
    emit Deposit(msg.sender, receiver, assets, shares);
    return shares;
}
```

**Reentrancy Protection**:
- State changes occur before external calls
- No opportunity for attacker to call back in bad state
- Additional guard: ReentrancyGuard on critical functions

---

## 4. ReentrancyGuard (Reentrancy Protection)

**Location**: `contracts/defi/ConstantProductAMM.sol`

**Usage**:
```solidity
function swap(uint256 amountIn, uint256 minAmountOut)
    external
    nonReentrant
    returns (uint256 amountOut)
{
    // Function logic
}
```

**Why Combined CEI + Guard?**
- CEI prevents most reentrancy paths
- Guard provides defense-in-depth for any missed cases
- Zero performance cost on second call (check, not revert until depth > 1)

---

## 5. Access Control / Role-Based Permissions

**Location**: All contracts requiring authorization

**Pattern**:
```
┌─────────────────────────────────┐
│ OpenZeppelin AccessControl      │
├─────────────────────────────────┤
│ Role 1: ADMIN_ROLE              │
│ Role 2: MINTER_ROLE             │
│ Role 3: PAUSER_ROLE             │
│ Role 4: UPGRADER_ROLE           │
└─────────────────────────────────┘
```

**Implementation**:
```solidity
contract RWAToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    
    function mint(address to, uint256 amount)
        public
        onlyRole(MINTER_ROLE)
    {
        _mint(to, amount);
    }
    
    function pause()
        public
        onlyRole(PAUSER_ROLE)
    {
        _pause();
    }
}
```

**vs Ownable**:
| Aspect | AccessControl | Ownable |
|--------|---|---|
| Multiple Admins | ✅ Yes | ❌ No |
| Granular Permissions | ✅ Yes | ❌ No |
| Gas Cost | Slightly Higher | Lower |
| Complexity | Moderate | Simple |

**Decision**: Use AccessControl for multi-role scenarios (preferred here).

---

## 6. Pausable / Circuit Breaker

**Location**: `RWAToken`, `RWAVault`

**Purpose**: Emergency protocol shutdown capability.

**Implementation**:
```solidity
contract RWAToken is ERC20, Pausable, AccessControl {
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }
    
    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
    
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
        whenNotPaused
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}
```

**When to Use**:
- ✅ Critical tokens (RWAToken)
- ✅ Vaults with fund locks
- ❌ Non-custodial functions (voting, queries)

---

## 7. State Machine (Proposal Lifecycle)

**Location**: `contracts/governance/RWAGovernor.sol`

**States**:
```
Pending → Active → Succeeded/Defeated
          (voting)      ↓
                    Queued (in Timelock)
                        ↓
                    Executed
```

**Implementation**:
```solidity
enum ProposalState {
    Pending,     // Waiting for voting to start
    Active,      // Voting in progress
    Canceled,    // Canceled before vote
    Defeated,    // Vote failed
    Succeeded,   // Vote passed
    Queued,      // Queued in Timelock
    Expired,     // Timelock window closed
    Executed     // Successfully executed
}

function state(uint256 proposalId)
    public
    view
    returns (ProposalState)
{
    // Logic to determine current state
}
```

**Why State Machine?**
- Clear state transitions
- Prevents invalid operations (e.g., execute while Pending)
- Easy to audit and verify correctness
- Event emission on state changes

---

## 8. Oracle Adapter / Interface Abstraction

**Location**: `contracts/oracles/ChainlinkPriceFeed.sol`

**Pattern**:
```
Protocol Code
    ↓
IChainlinkAggregator Interface
    ↓
├─ Real Chainlink Feed (Production)
├─ Mock Aggregator (Testing)
└─ Alternative Oracle (Future)
```

**Interface**:
```solidity
interface IAggregator {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

contract ChainlinkPriceFeed {
    IAggregator public aggregator;
    
    function setAggregator(address newAggregator)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        aggregator = IAggregator(newAggregator);
    }
}
```

**Benefits**:
- Swap implementations without changing client code
- Easy to test with mocks
- Supports oracle migration/rotation

---

## 9. Timelock (Delayed Execution)

**Location**: `RWATimelock` (OpenZeppelin TimelockController)

**Purpose**: Add delay between proposal approval and execution.

**Flow**:
```
Governor proposes → Timelock queues (operation) → Wait 2 days → Execute
```

**Configuration**:
```solidity
constructor(
    uint256 minDelay,       // 2 days (in seconds)
    address[] memory proposers,
    address[] memory executors,
    address admin
) TimelockController(minDelay, proposers, executors, admin) {}
```

**Why 2 Days?**
- Enough time to detect & respond to malicious proposals
- Aligns with governance standards
- Allows emergency pause if needed
- Balances security & responsiveness

---

## 10. Pull-over-Push Payments

**Location**: `ConstantProductAMM` (fee withdrawal), Vault (yield distribution)

**Anti-Pattern (Push)**:
```solidity
// ❌ NOT RECOMMENDED
function distributeFees() external {
    for (uint256 i = 0; i < feeRecipients.length; i++) {
        // Can fail on single recipient, blocking others
        require(feeRecipients[i].call{value: amounts[i]}(""));
    }
}
```

**Recommended (Pull)**:
```solidity
// ✅ RECOMMENDED
mapping(address => uint256) public pendingWithdrawals;

function claimFees() external {
    uint256 amount = pendingWithdrawals[msg.sender];
    require(amount > 0, "No fees");
    
    pendingWithdrawals[msg.sender] = 0;
    
    (bool success,) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}
```

**Benefits**:
- Failure in one withdrawal doesn't block others
- User controls when to withdraw (gas efficiency)
- No attack surface for fallback exploits

---

## 11. Summary Table

| Pattern | Location | Purpose | Necessity |
|---------|----------|---------|-----------|
| UUPS Proxy | RWAVault | Contract upgrades | ✅ Required |
| Factory | RWAFactory | Deterministic deployment | ✅ Required |
| CEI | All state-changing | Reentrancy prevention | ✅ Required |
| ReentrancyGuard | AMM, Vault | Defense-in-depth | ✅ Recommended |
| AccessControl | All privileged functions | Permission management | ✅ Required |
| Pausable | RWAToken, Vault | Emergency stop | ✅ Recommended |
| State Machine | Governor | Governance lifecycle | ✅ Required |
| Oracle Adapter | ChainlinkPriceFeed | Price feed abstraction | ✅ Recommended |
| Timelock | Governor | Delay governance | ✅ Required |
| Pull-over-Push | Fee/reward distribution | Safe payments | ✅ Required |

---

## Design Rationale

### Why These Patterns?

1. **Security First**: UUPS, CEI, Guards prevent major attack vectors
2. **Flexibility**: Factory, Adapter enable future enhancements
3. **Governance**: State Machine, Timelock ensure transparent decision-making
4. **User Protection**: Pull-over-Push, AccessControl prevent accidental fund loss
5. **Maintainability**: Clear patterns make code auditable & upgradeable

### Anti-Patterns Avoided

- ❌ Ownable (too centralized) → Use AccessControl
- ❌ Transparent Proxy (selector clash) → Use UUPS
- ❌ Push Payments (reentrancy) → Use Pull
- ❌ tx.origin checks (delegatecall breaks) → Use msg.sender
- ❌ block.timestamp for randomness → Use external oracle

---

## Validation Checklist

- [x] Each pattern serves a documented purpose
- [x] No over-engineering for unused features
- [x] All patterns tested in test suite
- [x] Consistent across codebase
- [x] Audit-friendly (clear intent)

---

**Document Version**: 1.0  
**Last Updated**: [Date]

