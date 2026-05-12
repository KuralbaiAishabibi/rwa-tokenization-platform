# RWA Tokenization Platform

## Overview

A comprehensive Real-World Asset (RWA) tokenization platform featuring ERC-20 asset-backed tokens, ERC-4626 yield vaults, Chainlink price feeds, role-gated minting, and full DAO governance with L2 deployment.

## Key Features

- **ERC-20 Governance Token** with voting power (ERC20Votes) and permit support (ERC20Permit)
- **RWA Token** - Asset-backed ERC-20 token with role-based minting control
- **ERC-4626 Yield Vault** - Tokenized vault for yield generation
- **Constant Product AMM** - x·y=k DEX with 0.3% fee and slippage protection
- **DAO Governance** - Full OpenZeppelin Governor stack with 2-day timelock
- **Chainlink Integration** - Price feeds with staleness checks
- **The Graph Indexing** - Complete subgraph for protocol events
- **L2 Deployment** - Verified on Arbitrum Sepolia, Optimism Sepolia, Base Sepolia, and zkSync Sepolia
- **UUPS Proxy Pattern** - Upgradeable contracts with upgrade path documentation
- **Factory Pattern** - CREATE and CREATE2 deployment mechanisms

## Project Structure

```
.
├── contracts/                    # Smart contracts
│   ├── core/                    # Core RWA token and vault logic
│   ├── tokens/                  # ERC20, ERC721, ERC1155 implementations
│   ├── governance/              # Governor, Timelock, voting contracts
│   ├── defi/                    # AMM and lending primitives
│   ├── oracles/                 # Chainlink oracle integrations
│   └── proxies/                 # UUPS proxy implementations
├── test/                        # Test suite
│   ├── unit/                    # Unit tests (50+ tests)
│   ├── fuzz/                    # Fuzz tests (10+ tests)
│   ├── invariant/               # Invariant tests (5+ tests)
│   └── fork/                    # Fork tests (3+ tests)
├── script/                      # Deployment scripts
├── frontend/                    # React dApp
│   ├── src/
│   │   ├── components/          # React components
│   │   ├── pages/               # Page components
│   │   ├── hooks/               # Custom React hooks
│   │   └── utils/               # Utility functions
│   └── public/
├── subgraph/                    # The Graph subgraph
├── docs/                        # Documentation
│   ├── ARCHITECTURE.md          # Architecture & design document (6+ pages)
│   ├── SECURITY_AUDIT.md        # Security audit report (8+ pages)
│   ├── GAS_OPTIMIZATION.md      # Gas optimization report
│   └── DESIGN_PATTERNS.md       # Design patterns documentation
└── foundry.toml                 # Foundry configuration
```

## Smart Contract Components

### Core Contracts

| Contract | Purpose | Pattern |
|----------|---------|---------|
| `RWAToken` | Main asset-backed token (ERC-20) | Access Control, Role-based |
| `RWAVault` | Yield vault (ERC-4626) | UUPS Proxy, Upgradeable |
| `RWAFactory` | Contract deployment | Factory, CREATE/CREATE2 |

### Governance Contracts

| Contract | Purpose |
|----------|---------|
| `GovernanceToken` | ERC20Votes + ERC20Permit |
| `RWAGovernor` | Governor implementation |
| `RWATimelock` | TimelockController (2-day delay) |

### DeFi Primitives

| Contract | Purpose |
|----------|---------|
| `ConstantProductAMM` | x·y=k DEX with 0.3% fee |
| `LPToken` | Liquidity provider tokens |

### Oracle Integration

| Contract | Purpose |
|----------|---------|
| `ChainlinkPriceFeed` | Chainlink price feed adapter |
| `MockAggregator` | Mock for testing |

## Security

### Standards Compliance
- ✅ Checks-Effects-Interactions (CEI) pattern
- ✅ ReentrancyGuard where applicable
- ✅ No tx.origin usage
- ✅ No deprecated ETH transfer (use call{value:})
- ✅ SafeERC20 for all token interactions
- ✅ Return value handling for external calls

### Access Control
- OpenZeppelin AccessControl for all privileged functions
- No unguarded admin functions
- Role-based minting authority

### Test Coverage
- **Unit Tests**: 50+ tests covering all public/external functions
- **Fuzz Tests**: 10+ tests (AMM swaps, vault deposits, governance voting)
- **Invariant Tests**: 5+ tests (k-invariant, supply conservation, accounting)
- **Fork Tests**: 3+ tests against real protocols
- **Coverage Target**: ≥90% line coverage

### Slither Validation
- Zero High findings
- Zero Medium findings
- All Low/Info findings documented and justified

## Testing

### Run All Tests
```bash
forge test -vvv
```

### Run Specific Test Categories
```bash
npm run test:unit          # Unit tests
npm run test:fuzz          # Fuzz tests
npm run test:invariant     # Invariant tests
npm run test:fork          # Fork tests
```

### Coverage Report
```bash
npm run coverage
```

### Gas Report
```bash
npm run gas-report
```

## Deployment

### Prerequisites
- Foundry installed: `curl -L https://foundry.paradigm.xyz | bash`
- Environment variables configured (see `.env.example`)
- L2 testnet RPC URLs and API keys

### Deploy to L2 Testnets

```bash
# Arbitrum Sepolia
npm run deploy:arbitrum

# Optimism Sepolia
npm run deploy:optimism

# Base Sepolia
npm run deploy:base

# zkSync Sepolia
npm run deploy:zksync
```

### Verified Contracts

| Network | Token | Vault | Governor | Links |
|---------|-------|-------|----------|-------|
| Arbitrum Sepolia | [Link] | [Link] | [Link] | Explorer |
| Optimism Sepolia | [Link] | [Link] | [Link] | Explorer |
| Base Sepolia | [Link] | [Link] | [Link] | Explorer |
| zkSync Sepolia | [Link] | [Link] | [Link] | Explorer |

## Frontend dApp

### Features
- Wallet connection (MetaMask + WalletConnect)
- Real-time balance and voting power display
- Protocol state queries (pool reserves, vault shares, positions)
- Interactive transactions (swap, deposit, vote)
- Active proposal list with voting interface
- The Graph integration for historical data
- Network detection and switching prompts
- Comprehensive error handling

### Run Frontend

```bash
cd frontend
npm install
npm run dev
```

### Build Frontend

```bash
npm run build
npm run start
```

## The Graph Subgraph

### Entities
- Users
- Tokens
- Vaults
- Proposals
- Votes
- Swaps
- Deposits
- Withdrawals

### Key Queries
- User balances and voting power
- Active proposals and voting status
- Vault performance and TVL
- DEX pool reserves and trading volume
- Treasury transactions

### Deploy Subgraph

```bash
cd subgraph
npm install
npm run codegen
npm run build
npm run deploy
```

## Documentation

### Architecture Document (6+ pages)
See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for:
- System context diagram (C4 Level 1)
- Component diagram with contract relationships
- Sequence diagrams for critical flows
- Data models and storage layouts
- Trust assumptions and security model
- Architecture Decision Records (ADRs)

### Security Audit Report (8+ pages)
See [docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md) for:
- Executive summary
- Scope and methodology
- Findings with severity levels
- Proof of concepts and recommendations
- Centralization analysis
- Governance attack analysis
- Oracle attack analysis
- Slither output

### Gas Optimization Report
See [docs/GAS_OPTIMIZATION.md](docs/GAS_OPTIMIZATION.md) for:
- Before/after benchmarks for 6+ operations
- Yul assembly optimization details
- Storage packing analysis
- Function selector optimization

## Design Patterns

The project demonstrates the following design patterns:

1. **UUPS Proxy** - Upgradeable contracts with V1 → V2 migration path
2. **Factory** - Efficient CREATE and CREATE2 deployment
3. **Checks-Effects-Interactions** - Secure external call ordering
4. **Access Control** - Role-based permission management
5. **ReentrancyGuard** - Protection against reentrancy attacks
6. **Pausable** - Emergency circuit breaker
7. **Oracle Adapter** - Chainlink feed abstraction
8. **Timelock** - Delayed governance execution
9. **Pull-over-Push** - Safe payment distribution
10. **State Machine** - Proposal lifecycle management

## Code Quality

### Formatting
```bash
npm run format              # Auto-format code
npm run format:check        # Check formatting
```

### Linting
```bash
npm run lint                # Run all linters
```

### Conventional Commits
All commits follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` New feature
- `fix:` Bug fix
- `test:` Test addition/modification
- `docs:` Documentation
- `refactor:` Code refactoring
- `chore:` Build/tooling changes
- `ci:` CI configuration

## Development

### Pre-commit Hooks
[TODO: Configure pre-commit hooks]

### IDE Setup
- VSCode with Solidity extension
- Prettier for formatting
- ESLint for JavaScript
- Solhint for Solidity

## Team

- [Team Member 1] - Smart Contracts
- [Team Member 2] - Frontend/Testing
- [Team Member 3] - Governance/Docs

## Milestone Tracking

| Week | Milestone | Status |
|------|-----------|--------|
| W6 | Team formed, scenario chosen | ⏳ |
| W7 | Core contracts compile, tests pass | ⏳ |
| W8 | DeFi + tokens complete, 50% coverage | ⏳ |
| W9 | Governance + oracles + L2 deploy | ⏳ |
| W10 | Full submission | ⏳ |

## License

MIT

## References

- [Solidity Docs](https://docs.soliditylang.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
- [Foundry Book](https://book.getfoundry.sh/)
- [Chainlink Docs](https://docs.chain.link/)
- [The Graph Docs](https://thegraph.com/docs/)

## Support

For questions or issues, please open a GitHub issue.
