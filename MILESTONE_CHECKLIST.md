# RWA Tokenization Platform - Development Checklist

## Project Setup ✅

- [x] Repository created
- [x] Directory structure established
- [x] Foundry configured (foundry.toml)
- [x] Package.json created
- [x] .gitignore configured
- [x] CI/CD pipeline created (.github/workflows)
- [ ] Team access configured
- [ ] Development environment set up

## Week 6: Foundation

- [ ] Team roster finalized
- [ ] Scenario (RWA Platform) confirmed
- [ ] Repository pushed to GitHub
- [ ] Initial commit with project structure
- [ ] Developer setup guide completed

**Deliverable**: Team roster + repo link

## Week 7: Core Contracts & Initial Tests

### Smart Contracts

- [ ] RWAToken (ERC-20) implemented
- [ ] GovernanceToken (ERC20Votes + ERC20Permit) implemented
- [ ] RWAFactory (CREATE + CREATE2) implemented
- [ ] Access control roles defined
- [ ] Pausable functionality added
- [ ] Compiler: 0.8.24 ✓
- [ ] All imports working

### Testing Foundation

- [ ] Unit test structure set up
- [ ] Basic unit tests for RWAToken (5+)
- [ ] Basic unit tests for Factory (3+)
- [ ] Tests passing locally
- [ ] Test runner configuration

### Infrastructure

- [ ] Solhint configured
- [ ] Prettier configured
- [ ] Conventional commit messages starting
- [ ] CI pipeline running (tests on push)

**Deliverable**: Compiling contracts + CI green + repo link

## Week 8: DeFi Primitive & 50% Coverage

### Smart Contracts

- [ ] ConstantProductAMM implemented
  - [ ] x·y=k invariant ✓
  - [ ] 0.3% fee ✓
  - [ ] Slippage protection ✓
  - [ ] LP tokens (ERC-20) ✓
- [ ] LPToken (ERC-20) implemented
- [ ] RWAVault (ERC-4626 UUPS Proxy)
  - [ ] Full ERC-4626 compliance ✓
  - [ ] UUPS pattern documented ✓
  - [ ] Initialize function working ✓
- [ ] Chainlink price feed adapter
  - [ ] Staleness check (< 1 hour) ✓
  - [ ] Mock aggregator for tests ✓

### Testing (50% Coverage Target)

- [ ] Unit tests: 25+
  - [ ] Swap functions ✓
  - [ ] Liquidity management ✓
  - [ ] Vault deposits/withdrawals ✓
  - [ ] Price feed queries ✓
- [ ] Fuzz tests: 3+ (AMM, Vault)
- [ ] Basic coverage report generated
- [ ] All tests passing

### Code Quality

- [ ] Access control implemented everywhere
- [ ] Checks-Effects-Interactions pattern used
- [ ] SafeERC20 on all token interactions
- [ ] ReentrancyGuard on critical functions
- [ ] No deprecated patterns (tx.origin, send, transfer)
- [ ] Code formatted (forge fmt)
- [ ] Linting passing

**Deliverable**: Mid-project review checkpoint + contracts compile + tests passing

## Week 9: Governance & L2 Deployment

### Smart Contracts

- [ ] RWAGovernor implemented
  - [ ] 1 day voting delay ✓
  - [ ] 1 week voting period ✓
  - [ ] 4% quorum ✓
  - [ ] 1% proposal threshold ✓
- [ ] RWATimelock implemented
  - [ ] 2 day delay ✓
  - [ ] Treasury control ✓
- [ ] Governance token delegation setup
- [ ] End-to-end governance flow testable
  - [ ] Propose → Vote → Queue → Execute ✓

### Testing (80%+ Coverage)

- [ ] Unit tests: 50+
- [ ] Fuzz tests: 10+ (including governance voting)
- [ ] Invariant tests: 5+
  - [ ] k-invariant (never decreases) ✓
  - [ ] Total supply conservation ✓
- [ ] Coverage report: ≥80%
- [ ] Slither: 0 High, 0 Medium

### L2 Deployment

- [ ] Choose L2 network (Arbitrum Sepolia preferred)
- [ ] Deployment script created
  - [ ] Parameterized ✓
  - [ ] Idempotent ✓
  - [ ] Verification script ✓
- [ ] Test deployment locally (--dry-run)
- [ ] Deploy to Arbitrum Sepolia
  - [ ] RWAToken verified ✓
  - [ ] GovernanceToken verified ✓
  - [ ] Governor verified ✓
  - [ ] Timelock verified ✓
  - [ ] Vault verified ✓
  - [ ] AMM verified ✓
  - [ ] Price Feed verified ✓
- [ ] Links added to README

### The Graph (Subgraph)

- [ ] subgraph.yaml created
- [ ] schema.graphql defined
  - [ ] Users entity ✓
  - [ ] Tokens entity ✓
  - [ ] Proposals entity ✓
  - [ ] Votes entity ✓
  - [ ] Swaps entity ✓
  - [ ] Deposits entity ✓
- [ ] Mappings written
- [ ] Local testing with graph-cli
- [ ] Deployed to The Graph Studio

**Deliverable**: Testnet addresses + subgraph live

## Week 10: Full Submission

### Smart Contracts

- [ ] All required components complete
- [ ] Advanced Solidity (Lecture 1)
  - [ ] UUPS proxy + V1→V2 upgrade path ✓
  - [ ] Factory with CREATE + CREATE2 ✓
  - [ ] Yul assembly (1+ contract) ✓
- [ ] Token standards (Lecture 6)
  - [ ] ERC-20 (RWAToken) ✓
  - [ ] ERC-20 Votes + Permit (GovernanceToken) ✓
  - [ ] ERC-4626 (RWAVault) ✓
  - [ ] Rounding invariants passing ✓
- [ ] DeFi primitives (Lectures 4 & 5)
  - [ ] AMM (x·y=k) built from scratch ✓
- [ ] Oracles (Lecture 8)
  - [ ] Chainlink integration ✓
  - [ ] Staleness check ✓
  - [ ] Mock aggregator ✓
- [ ] Governance (Lecture 9)
  - [ ] Governor + Timelock + Votes ✓
  - [ ] Full lifecycle demonstrated ✓
- [ ] L2 deployment complete and verified ✓

### Testing (Final)

- [ ] Unit tests: ≥50 passing ✓
- [ ] Fuzz tests: ≥10 passing ✓
- [ ] Invariant tests: ≥5 passing ✓
- [ ] Fork tests: ≥3 passing ✓
- [ ] Coverage: ≥90% ✓
- [ ] All tests pass in CI ✓

### Security

- [ ] Slither: 0 High, 0 Medium ✓
- [ ] Security audit report (8+ pages)
  - [ ] Executive summary ✓
  - [ ] Scope & methodology ✓
  - [ ] Findings (with Low/Info) ✓
  - [ ] 2 reproduced vulnerabilities ✓
  - [ ] Governance attack analysis ✓
  - [ ] Oracle attack analysis ✓
  - [ ] Centralization analysis ✓
- [ ] All low findings addressed/documented ✓

### Frontend dApp

- [ ] Wallet connection (MetaMask + WalletConnect)
- [ ] Balance display (RWA, GOV, shares, voting power)
- [ ] State queries (1+ protocol-specific)
- [ ] Write functions: 3+ transactions
  - [ ] Swap ✓
  - [ ] Deposit ✓
  - [ ] Vote ✓
- [ ] Proposal list with states
- [ ] Vote interface
- [ ] Graph integration (1+ section)
- [ ] Error handling (network, balance, rejection)
- [ ] Network detection

### Documentation

- [ ] README.md (comprehensive)
  - [ ] Overview ✓
  - [ ] Features ✓
  - [ ] Project structure ✓
  - [ ] Smart contract components ✓
  - [ ] Testing instructions ✓
  - [ ] Deployment instructions ✓
  - [ ] Verified contract links ✓

- [ ] Architecture & Design (6+ pages)
  - [ ] System context diagram ✓
  - [ ] Component diagram ✓
  - [ ] Sequence diagrams (3+) ✓
  - [ ] Data models & storage layout ✓
  - [ ] Trust assumptions ✓
  - [ ] ADRs (Architecture Decision Records) ✓

- [ ] Security Audit Report (8+ pages)
  - [ ] Executive summary ✓
  - [ ] Scope & methodology ✓
  - [ ] Findings table ✓
  - [ ] Detailed findings ✓
  - [ ] Vulnerability case studies (2+) ✓
  - [ ] Governance attack analysis ✓
  - [ ] Oracle attack analysis ✓
  - [ ] Slither output ✓

- [ ] Gas Optimization Report
  - [ ] Before/after benchmarks (6+ ops) ✓
  - [ ] Yul assembly details ✓
  - [ ] L2 gas considerations ✓

- [ ] Design Patterns Documentation
  - [ ] 5+ patterns documented ✓
  - [ ] Usage justified ✓

### DevOps

- [ ] GitHub Actions CI
  - [ ] Compile tests passing ✓
  - [ ] Coverage reporting ✓
  - [ ] Slither integration ✓
  - [ ] PR status checks ✓
- [ ] Pre-commit hooks OR lint in CI
  - [ ] forge fmt --check ✓
  - [ ] solhint ✓
  - [ ] Prettier ✓
- [ ] Conventional commits throughout ✓
- [ ] All contracts deployed on L2 ✓
- [ ] Verified on block explorer ✓

### Submission

- [ ] All files checked into GitHub
- [ ] Deployment script runs (--broadcast)
- [ ] Verification script works
- [ ] Post-deployment checks pass
- [ ] Final presentation slides (PDF)
  - [ ] Architecture overview ✓
  - [ ] Key features ✓
  - [ ] Security measures ✓
  - [ ] Test coverage ✓
  - [ ] Gas optimizations ✓
  - [ ] Deployment & verification ✓
  - [ ] Lessons learned ✓

### Presentation Prep (Week 10)

- [ ] Team presentation divided
- [ ] Each member prepared on full system
- [ ] Slides complete (15 min + 10 min Q&A)
- [ ] Demo ready (or video recording)
- [ ] Responses prepared for common Q&A

**Deliverable**: Full submission + presentation

---

## Grading Focus Areas

### Smart Contracts (20 pts)
- ✅ All components implemented
- ✅ UUPS proxy with V1→V2 path
- ✅ Factory (CREATE + CREATE2)
- ✅ Yul assembly optimization
- ✅ ERC-20, ERC-20Votes, ERC-4626
- ✅ AMM with invariants
- ✅ Chainlink integration

### Security (15 pts)
- ✅ Access control properly implemented
- ✅ Checks-Effects-Interactions
- ✅ No unguarded admin functions
- ✅ Slither: 0 High/Medium
- ✅ Security audit report comprehensive
- ✅ Vulnerability case studies

### Testing (15 pts)
- ✅ 80+ tests total
- ✅ 50+ unit tests
- ✅ 10+ fuzz tests
- ✅ 5+ invariant tests
- ✅ 3+ fork tests
- ✅ ≥90% coverage

### Code Quality (10 pts)
- ✅ Design patterns (5+) documented
- ✅ Readable, maintainable code
- ✅ Proper naming conventions
- ✅ Clear comments

### Frontend + Subgraph (10 pts)
- ✅ Wallet connection works
- ✅ Transactions from UI
- ✅ Proposal voting UI
- ✅ Graph integration
- ✅ Error handling

### Deployment (5 pts)
- ✅ L2 testnet deployment
- ✅ Verified contracts
- ✅ Script reproducible
- ✅ Documentation links

---

## Notes for Team

1. **Start Early**: Don't wait until Week 9 for L2 deployment
2. **Test Continuously**: Run tests frequently, catch issues early
3. **Document as You Go**: Architecture & design easier to write incrementally
4. **Security First**: Build security in, not on after
5. **Communication**: Keep code review standards high
6. **Presentation**: Practice presenting - Q&A is critical

---

**Last Updated**: [Date]
