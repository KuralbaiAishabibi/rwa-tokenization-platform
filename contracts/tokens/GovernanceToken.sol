// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title GovernanceToken
 * @dev ERC-20 governance token with voting power and permit support
 * 
 * Features:
 * - ERC20Votes: Voting delegation and balance snapshots
 * - ERC20Permit: Permit-based approvals
 * - Burnable: Token holders can burn their tokens
 * - Capped: Maximum supply cap
 * 
 * Design Patterns:
 * - Voting snapshots: Prevent flash loan attacks
 * - Delegation: Users must explicitly delegate voting power
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GovernanceToken is 
    ERC20, 
    ERC20Votes, 
    ERC20Permit, 
    ERC20Burnable,
    ERC20Capped,
    Ownable
{
    // ============ Constructor ============
    /**
     * @param initialSupply Initial token supply
     * @param maxSupply Maximum token cap
     */
    constructor(
        uint256 initialSupply,
        uint256 maxSupply
    )
        ERC20("RWA Governance Token", "GOV")
        ERC20Permit("RWA Governance Token")
        ERC20Capped(maxSupply)
        Ownable(msg.sender)
    {
        require(initialSupply <= maxSupply, "Initial supply exceeds cap");
        _mint(msg.sender, initialSupply);
    }

    // ============ Minting ============
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // ============ Internal Overrides ============
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes, ERC20Capped) {
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
}
