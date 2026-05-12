# Quick Start Guide

Get up and running with the RWA Tokenization Platform in minutes.

## Prerequisites

1. **Git**: [Download](https://git-scm.com/)
2. **Foundry**: Install Rust and Foundry
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```
3. **Node.js**: v18+ [Download](https://nodejs.org/)
4. **MetaMask**: Browser extension [Install](https://metamask.io/)

## Initial Setup

### 1. Clone Repository
```bash
git clone https://github.com/your-org/final-blockchain.git
cd final-blockchain
```

### 2. Install Dependencies
```bash
# Install Foundry dependencies
forge install

# Install Node.js dependencies
npm install
```

### 3. Configure Environment
```bash
# Copy example environment file
cp .env.example .env

# Edit .env with your values
nano .env
# or
code .env
```

**Required for deployment:**
- `PRIVATE_KEY`: Your wallet's private key (for deploying contracts)
- `ARBITRUM_SEPOLIA_RPC_URL`: Arbitrum testnet RPC URL

### 4. Compile Contracts
```bash
forge build
```

Expected output:
```
Compiling 25 files with 0.8.24
Solc 0.8.24 finished in 2.50s
Compiler run successful!
```

## Running Tests

### Unit Tests
```bash
forge test --match-path "test/unit/*"
```

### All Tests
```bash
npm run test
```

### Specific Test File
```bash
forge test --match-path "test/unit/RWAToken.t.sol"
```

### With Gas Report
```bash
FORGE_GAS_REPORT=true forge test
```

### Coverage
```bash
npm run coverage
```

## Deploying to Testnet

### 1. Get Testnet ETH
- [Arbitrum Sepolia Faucet](https://faucet.arbitrum.io/)
- [Optimism Sepolia Faucet](https://www.sepoliafaucet.io/)
- [Base Sepolia Faucet](https://faucet.base.org/)

### 2. Deploy Contracts
```bash
# Arbitrum Sepolia
npm run deploy:arbitrum

# Optimism Sepolia
npm run deploy:optimism

# Base Sepolia
npm run deploy:base
```

### 3. Note Contract Addresses
After successful deployment, save the contract addresses printed to console.

### 4. Verify Contracts
```bash
forge verify-contract \
  --chain-id 421614 \
  --etherscan-api-key $ARBISCAN_API_KEY \
  <CONTRACT_ADDRESS> \
  contracts/tokens/RWAToken.sol:RWAToken
```

## Frontend Development

### 1. Install Frontend Dependencies
```bash
cd frontend
npm install
```

### 2. Run Development Server
```bash
npm run dev
```

Server runs at `http://localhost:5173`

### 3. Update Contract Addresses
Edit `frontend/src/config.ts`:
```typescript
export const CONTRACTS = {
  arbitrumSepolia: {
    rwaToken: '0x...',
    govToken: '0x...',
    // ... other addresses
  },
};
```

## Code Quality

### Format Code
```bash
npm run format
```

### Check Formatting
```bash
npm run format:check
```

### Run Linters
```bash
npm run lint
```

### Slither Security Analysis
```bash
npm run slither
```

## Common Issues & Fixes

### Issue: "Permission denied" on foundryup
**Solution**: 
```bash
chmod +x ~/.foundry/bin/foundryup
```

### Issue: "No such file or directory: forge"
**Solution**: Add Foundry to PATH
```bash
export PATH="$PATH:~/.foundry/bin"
```

### Issue: "Error: Invalid RPC URL"
**Solution**: 
1. Check `.env` file is copied and filled
2. Verify RPC URL format
3. Test with: `curl <RPC_URL>`

### Issue: "Private key not provided"
**Solution**: 
1. Make sure `PRIVATE_KEY` is in `.env`
2. Never commit `.env` to git
3. Use test accounts: `cast wallet new` to generate

### Issue: Gas limit exceeded
**Solution**: 
1. Try deploying to different network
2. Optimize deployment script
3. Use testnet with lower base fee

## Git Workflow

### First Time Setup
```bash
git config user.name "Your Name"
git config user.email "your@email.com"
```

### Feature Development
```bash
# Create feature branch
git checkout -b feat/your-feature

# Make changes and commit
git add .
git commit -m "feat: description of your change"

# Push to GitHub
git push origin feat/your-feature

# Create pull request on GitHub
```

### Conventional Commits
- `feat:` New feature
- `fix:` Bug fix
- `test:` Test additions
- `docs:` Documentation
- `refactor:` Code refactoring
- `chore:` Maintenance

### Example
```bash
git commit -m "feat(vault): implement deposit with slippage protection"
git commit -m "fix(amm): correct k-invariant rounding"
git commit -m "test(governance): add voting delegation tests"
```

## Project Structure Quick Reference

```
contracts/           Smart contracts (Solidity)
├── core/           Core logic (tokens, vault)
├── tokens/         Token implementations
├── governance/     Governor, Timelock
├── defi/          AMM, lending primitives
└── oracles/       Oracle integrations

test/               Test files (Solidity)
├── unit/          Unit tests (50+)
├── fuzz/          Fuzz tests (10+)
├── invariant/     Invariant tests (5+)
└── fork/          Fork tests (3+)

frontend/           React dApp
├── src/
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   └── utils/
└── public/

docs/               Documentation
├── ARCHITECTURE.md         6+ pages
├── SECURITY_AUDIT.md       8+ pages
├── GAS_OPTIMIZATION.md
└── DESIGN_PATTERNS.md

script/             Deployment scripts
└── Deploy.s.sol    Main deployment
```

## Next Steps

1. **Review Architecture**: Read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)
2. **Understand Patterns**: Check [docs/DESIGN_PATTERNS.md](docs/DESIGN_PATTERNS.md)
3. **Write Tests**: Add more tests in `test/unit/`
4. **Deploy**: Follow deployment guide above
5. **Integrate Frontend**: Connect UI to deployed contracts

## Useful Commands

```bash
# Get account info
cast account <ADDRESS>

# Check balance
cast balance <ADDRESS> --rpc-url $ARBITRUM_SEPOLIA_RPC_URL

# Send transaction
cast send <TO> "<FUNCTION_SIGNATURE>" [ARGS] --private-key $PRIVATE_KEY

# Generate new wallet
cast wallet new

# Encode function call
cast calldata "mint(address,uint256)" 0x... 1000ether

# Decode event logs
cast decode-log "<SIGNATURE>" <TOPIC1> <DATA>
```

## Useful Links

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Docs](https://docs.soliditylang.org/)
- [OpenZeppelin Docs](https://docs.openzeppelin.com/contracts/)
- [Chainlink Docs](https://docs.chain.link/)
- [The Graph Docs](https://thegraph.com/docs/)
- [Ethers.js Docs](https://docs.ethers.org/v6/)

## Getting Help

1. **Check existing issues**: Search GitHub issues
2. **Read docs**: Documentation is comprehensive
3. **Stack Overflow**: Tag questions with `solidity`, `foundry`
4. **Discord**: Join Foundry Discord for community support

## Security Reminders

⚠️ **IMPORTANT**:
- Never commit `.env` to git
- Never share private keys
- Test on testnet first
- Review security audit before mainnet
- Use hardware wallet for production keys

---

**Need help?** Check MILESTONE_CHECKLIST.md for project phases and requirements.

**Last Updated**: [Date]
