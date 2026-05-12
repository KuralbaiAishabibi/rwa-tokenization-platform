# RWA Tokenization Platform - Architecture & Design Document

## Document Information
- **Version**: 1.0
- **Date**: [Update with current date]
- **Team**: [Team name]
- **Status**: Draft / Final

---

## 1. Executive Summary

This document describes the architecture of the RWA Tokenization Platform, a sophisticated blockchain protocol combining real-world asset tokenization, decentralized governance, yield farming, and multi-chain deployment. The platform enables regulated issuers to mint asset-backed ERC-20 tokens, users to participate in yield vaults (ERC-4626), trade on a decentralized exchange (AMM), and govern protocol parameters through a DAO.

### Key Components
- **ERC-20 Asset-Backed Token** with role-based minting
- **ERC-4626 Yield Vault** for passive income generation
- **Constant Product AMM** (x·y=k) with 0.3% fees
- **DAO Governance** with 2-day timelock
- **Chainlink Integration** for real-world price feeds
- **The Graph Indexing** for off-chain data access
- **L2 Deployment** across 4 blockchain networks

---

## 2. System Context Diagram (C4 Level 1)

```
┌─────────────────────────────────────────────────────────────┐
│                    External Systems                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Chainlink Oracle Network                   │  │
│  │  - Price Feeds (RWA/ETH, ETH/USD, etc.)             │  │
│  │  - Proof of Reserve                                  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         The Graph Protocol                           │  │
│  │  - Event Indexing                                    │  │
│  │  - Historical Data Query                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Wallet Services                              │  │
│  │  - MetaMask                                          │  │
│  │  - WalletConnect                                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │
                ┌─────────────┴──────────────┐
                │                            │
        ┌───────▼────────┐         ┌────────▼────────┐
        │   Smart        │         │   Frontend      │
        │   Contracts    │         │   dApp (React)  │
        │ (L2 Blockchains)         │                 │
        └────────────────┘         └─────────────────┘
```

---

## 3. Container & Component Diagram

### 3.1 Smart Contract Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         RWA Tokenization Platform                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌────────────────────────────┐  ┌──────────────────────────────────┐  │
│  │   Token Layer              │  │  Governance Layer                │  │
│  ├────────────────────────────┤  ├──────────────────────────────────┤  │
│  │ • RWAToken (ERC-20)        │  │ • GovernanceToken (ERC20Votes)   │  │
│  │   - Minter role            │  │   - ERC20Permit                  │  │
│  │   - Pauser role            │  │ • RWAGovernor                    │  │
│  │ • RWAVault (ERC-4626)      │  │   - Voting delay: 1 day          │  │
│  │   - UUPS Proxy V1/V2       │  │   - Voting period: 1 week        │  │
│  │   - Deposit/Withdraw       │  │   - Quorum: 4%                   │  │
│  │ • RWAFactory               │  │ • RWATimelock                    │  │
│  │   - CREATE/CREATE2         │  │   - Delay: 2 days                │  │
│  │                            │  │   - Treasury control              │  │
│  └────────────────────────────┘  └──────────────────────────────────┘  │
│                                                                           │
│  ┌────────────────────────────┐  ┌──────────────────────────────────┐  │
│  │   DeFi Layer               │  │  Oracle & Indexing Layer         │  │
│  ├────────────────────────────┤  ├──────────────────────────────────┤  │
│  │ • ConstantProductAMM       │  │ • ChainlinkPriceFeed             │  │
│  │   - Swap function          │  │   - Price staleness check        │  │
│  │   - 0.3% fee               │  │   - Fallback mechanism           │  │
│  │   - Slippage protection    │  │ • MockAggregator (testing)       │  │
│  │ • LPToken (ERC-20)         │  │ • Subgraph (The Graph)           │  │
│  │   - Minting on add liquidity│ │   - Event indexing               │  │
│  │   - Burning on remove      │  │   - Historical queries           │  │
│  └────────────────────────────┘  └──────────────────────────────────┘  │
│                                                                           │
│  ┌────────────────────────────────────────────────────────────────────┐ │
│  │                      Security Layer                                 │ │
│  ├────────────────────────────────────────────────────────────────────┤ │
│  │ • ReentrancyGuard on all external calls                            │ │
│  │ • AccessControl (Roles): ADMIN, MINTER, PAUSER, GOVERNANCE        │ │
│  │ • Pausable: Emergency circuit breaker                              │ │
│  │ • SafeERC20: All token interactions                                │ │
│  │ • Yul Assembly: Gas-optimized critical paths                       │ │
│  └────────────────────────────────────────────────────────────────────┘ │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Frontend Architecture

```
┌────────────────────────────────────────────────────────┐
│              Frontend dApp (React)                      │
├────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │         Pages                                    │ │
│  │  • Dashboard (Portfolio)                         │ │
│  │  • Trading (Swap)                                │ │
│  │  • Vault (Deposit/Withdraw)                      │ │
│  │  • Governance (Proposals/Voting)                 │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │         Custom Hooks (React)                     │ │
│  │  • useWallet() - MetaMask/WalletConnect         │ │
│  │  • useTokenBalance() - Real-time balance        │ │
│  │  • useVotingPower() - Delegation & voting       │ │
│  │  • useSubgraph() - The Graph queries            │ │
│  │  • useTransaction() - TX status tracking        │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │         Components                              │ │
│  │  • WalletConnect                                │ │
│  │  • BalanceDisplay                               │ │
│  │  • SwapInterface                                │ │
│  │  • VaultForm                                    │ │
│  │  • ProposalCard                                 │ │
│  │  • VoteInterface                                │ │
│  │  • ErrorBoundary                                │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
│  ┌──────────────────────────────────────────────────┐ │
│  │         Utilities                               │ │
│  │  • ethers.js / Viem integration                │ │
│  │  • Contract ABIs                               │ │
│  │  • Address constants (by network)              │ │
│  │  • Error handling & formatting                 │ │
│  └──────────────────────────────────────────────────┘ │
│                                                         │
└────────────────────────────────────────────────────────┘
```

---

## 4. Sequence Diagrams

### 4.1 RWA Token Minting Flow

```
User          Frontend       RWAToken        Governance        Timelock
 │               │               │                │                │
 │─ Request ──→  │               │                │                │
 │               │               │                │                │
 │            [Connect Wallet]   │                │                │
 │               │               │                │                │
 │               │─ mint() ─────→│                │                │
 │               │               │ (check role)   │                │
 │               │               │ (update supply)│                │
 │               │               │                │                │
 │            ✓  │←─ Confirm ────│                │                │
 │ ←─ Success ────│               │                │                │
```

### 4.2 Governance Voting Flow

```
User          Frontend      GovernanceToken    Governor      Timelock
 │               │                │               │              │
 │─ Delegate ─→  │                │               │              │
 │               │─ delegate()──→ │ (update votes)│              │
 │               │                │               │              │
 │           [Wait 1 day]         │               │              │
 │               │                │               │              │
 │─ Propose ───→ │                │               │              │
 │               │─ propose()────────────────────→│              │
 │               │                │               │ (enqueue)    │
 │               │                │               │              │
 │           [Wait 1 week]         │               │              │
 │               │                │               │              │
 │─ Vote ───────→│                │               │              │
 │               │─ castVote()───────────────────→│              │
 │               │                │               │              │
 │           [Wait + execute] ────────────────────→ queue()     │
 │               │                │               │──→ execute()│
 │               │                │               │              │
 │ ←─ Success ────│                │               │              │
```

### 4.3 Vault Deposit & Withdrawal Flow

```
User          Frontend       RWAVault         PriceFeed      Underlying Token
 │               │               │                │                │
 │─ Deposit ────→│               │                │                │
 │               │               │                │                │
 │               │─ deposit()───→│                │                │
 │               │               │ (check price)──→                │
 │               │               │                                 │
 │               │               │ (transferFrom)───────────────→ │
 │               │               │ ←──── Success ────────────────│
 │               │               │ (mint shares)                   │
 │               │               │                                │
 │            ✓  │←─ Shares ─────│                               │
 │ ←─ Confirm ────│               │                               │
 │               │               │                               │
 │─ Withdraw ───→│               │                               │
 │               │               │                               │
 │               │─ withdraw()──→│                               │
 │               │               │ (burn shares)                  │
 │               │               │ (transfer underlying)─────────→│
 │               │               │                     Success ──│
 │            ✓  │←─ Tokens ─────│                               │
 │ ←─ Confirm ────│               │                               │
```

---

## 5. Data Model & Storage Layout

### 5.1 RWAToken Storage (ERC-20 with Access Control)

```solidity
contract RWAToken is ERC20, AccessControl, Pausable {
    // Slot 0: ERC20._balances (mapping)
    // Slot 1: ERC20._allowances (mapping)
    // Slot 2: ERC20._totalSupply (uint256)
    // Slot 3: ERC20._name (string)
    // Slot 4: ERC20._symbol (string)
    // Slot 5: AccessControl._roles (mapping)
    // Slot 6: Pausable._paused (bool)
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
}
```

### 5.2 RWAVault Storage (ERC-4626 UUPS Proxy)

```solidity
contract RWAVault is ERC4626, UUPSUpgradeable, AccessControl {
    // ERC20 storage for shares
    // Slot 0-5: As ERC-20 (inherited)
    
    // ERC4626 specific
    address public asset;
    
    // Custom state
    uint256 public totalShares;
    uint256 public totalAssets;
    
    // Access control for upgrades
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
}
```

### 5.3 Governor Storage

```solidity
contract RWAGovernor is Governor {
    // Storage slots:
    // 0: Governor._currentNonce
    // 1: Governor._proposalDetails
    // 2: Governor._proposalVotes
    // 3: Governor._proposalSnapshots
    
    uint256 public constant VOTING_DELAY = 1 days;      // 1 day
    uint256 public constant VOTING_PERIOD = 1 weeks;    // 1 week
    uint256 public constant QUORUM_FRACTION = 4;        // 4%
}
```

### 5.4 ConstantProductAMM Storage

```solidity
contract ConstantProductAMM is ReentrancyGuard {
    mapping(address => uint256) public reserves;        // Token reserves
    uint256 public k;                                   // Invariant
    address public token0;
    address public token1;
    uint256 public constant FEE = 3;                   // 0.3% in basis points
    
    // LP token state
    mapping(address => uint256) public lpBalance;
    uint256 public totalLPSupply;
}
```

---

## 6. Trust Assumptions & Security Model

### 6.1 Trust Boundaries

| Role | Permissions | Constraints |
|------|-------------|-------------|
| **Admin** | Pause/unpause, role management | Controlled by Timelock (2-day delay) |
| **Minter** | Mint RWA tokens | Must be KYC-verified issuer |
| **Governor** | Protocol parameter changes | Requires DAO vote |
| **Timelock** | Executes proposals after delay | Non-custodial, transparent |
| **Users** | Swap, deposit, vote | No centralized control |

### 6.2 Attack Vectors Mitigated

1. **Reentrancy**: ReentrancyGuard + CEI pattern
2. **Flash Loan Governance**: Voting power snapshot at proposal block
3. **Price Manipulation**: Chainlink feed with staleness check
4. **Sandwich Attacks**: Slippage protection on swaps
5. **Access Control Bypass**: Role-based AccessControl (no tx.origin)
6. **Integer Overflow**: Solidity 0.8.24+ with checked arithmetic
7. **Oracle Failure**: Fallback mechanism for price feeds

### 6.3 Multisig Security (if applicable)

If a multisig controls the Timelock:
- M-of-N signing required
- Key management policy
- Emergency pause capability
- Upgrade authority

---

## 7. Design Decisions (ADR)

### ADR-001: UUPS Proxy Pattern

**Context**: Need for contract upgradeability without delegatecall vulnerabilities.

**Decision**: Use UUPS (Universal Upgradeable Proxy Standard) instead of transparent proxy.

**Rationale**:
- Upgrade logic in implementation (not proxy)
- No admin function selector clash
- Smaller proxy bytecode
- Better gas efficiency

**Implementation**: `RWAVault` uses `UUPSUpgradeable` with `_authorizeUpgrade()` gated by `UPGRADER_ROLE`.

---

### ADR-002: Constant Product AMM

**Context**: Need decentralized trading without complex order books.

**Decision**: Implement x·y=k AMM with 0.3% fee (Uniswap V2 inspired).

**Rationale**:
- Simple, proven mechanism
- Capital efficient
- Composable with other protocols
- Easy to test invariants

**Trade-off**: Impermanent loss for LPs, but transparent.

---

### ADR-003: Timelock Delay (2 days)

**Context**: Balance between governance responsiveness and security.

**Decision**: 2-day delay for all governance actions.

**Rationale**:
- Long enough to react to malicious proposals
- Short enough for market-responsive adjustments
- Aligns with major DAO standards (MakerDAO, Compound)

---

### ADR-004: Chainlink Price Feed with Staleness Check

**Context**: Need reliable, manipulation-resistant price data.

**Decision**: Chainlink aggregator with `updatedAt` validation.

**Rationale**:
- Decentralized oracle network
- Multiple data sources
- Transparent validator set
- Staleness threshold = 1 hour

---

### ADR-005: ERC-4626 for Yield Vault

**Context**: Standardize vault interface for composability.

**Decision**: Implement full ERC-4626 with passing audit.

**Rationale**:
- Standard interface for vaults
- Enable permissionless composability
- Rounding invariants ensure user protection

---

### ADR-006: Role-Based Access Control

**Context**: Granular permission management without tight coupling.

**Decision**: OpenZeppelin AccessControl (role-based) vs Ownable.

**Rationale**:
- Supports multiple admins
- Explicit role semantics
- Easier to audit and understand
- Compatible with multisig

---

## 8. Critical User Flows

### Flow 1: Mint RWA Token
1. User submits KYC
2. Admin grants MINTER_ROLE
3. Minter calls `mint(address to, uint256 amount)`
4. RWAToken supply increases
5. User receives tokens

### Flow 2: Governance Vote-to-Execute
1. Governor proposes parameter change
2. Users delegate tokens to themselves (if not already)
3. Wait 1 day (VOTING_DELAY)
4. Voting period: 1 week
5. If quorum (4%) and majority voting FOR:
   - Proposal transitions to SUCCEEDED
6. Governor queues proposal in Timelock
7. Wait 2 days
8. Governor executes proposal (or anyone calls execute)
9. State change takes effect

### Flow 3: Vault Deposit & Earn
1. User approves underlying token
2. Calls `deposit(uint256 assets, address receiver)`
3. Contract transfers underlying assets
4. Vault mints share tokens to receiver
5. Shares earn yield from protocol fees/external integrations
6. User calls `redeem(uint256 shares, address receiver, address owner)`
7. Vault burns shares, transfers underlying back

---

## 9. External Dependencies

| Dependency | Version | Purpose |
|------------|---------|---------|
| OpenZeppelin Contracts | ^5.0.0 | Access Control, Governor, ERC standards |
| Chainlink Contracts | ^1.0.0 | Price feed interface |
| Foundry | Latest | Testing, deployment |
| The Graph | Latest | Event indexing |
| ethers.js | ^6.0.0 | Frontend blockchain interaction |

---

## 10. Deployment & Verification

### L2 Testnets
- **Arbitrum Sepolia**: [Contract Addresses]
- **Optimism Sepolia**: [Contract Addresses]
- **Base Sepolia**: [Contract Addresses]
- **zkSync Sepolia**: [Contract Addresses]

### Verification Process
```bash
# Example
forge verify-contract \
  --chain-id 421614 \
  --etherscan-api-key $ARBISCAN_API_KEY \
  0x1234... RWAToken
```

---

## 11. Gas Optimization Summary

(Detailed in [GAS_OPTIMIZATION.md](GAS_OPTIMIZATION.md))

| Operation | Before | After | Savings |
|-----------|--------|-------|---------|
| Swap | 85,000 | 72,000 | 15.3% |
| Deposit | 125,000 | 98,000 | 21.6% |
| Vote | 95,000 | 78,000 | 17.9% |

---

## 12. Diagram Sources

[Mermaid/PlantUML source files for regeneration]

---

## Appendix A: Glossary

- **RWA**: Real-World Asset
- **AMM**: Automated Market Maker
- **ERC-4626**: Tokenized Vault Standard
- **Timelock**: Delay mechanism for governance
- **Slippage**: Price change between quote and execution
- **Impermanent Loss**: LP loss from price divergence

---

## Appendix B: References

- [EIP-20: ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)
- [EIP-4626: Tokenized Vault Standard](https://eips.ethereum.org/EIPS/eip-4626)
- [OpenZeppelin Governor](https://docs.openzeppelin.com/contracts/5.x/governance)
- [Chainlink Price Feeds](https://docs.chain.link/docs/using-price-feeds)

---

**Document Version**: 1.0  
**Last Updated**: [Date]  
**Next Review**: [Date + 30 days]

