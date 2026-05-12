// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../contracts/tokens/RWAToken.sol";

contract RWATokenTest is Test {
    RWAToken token;
    address admin = address(0x1);
    address minter = address(0x2);
    address user1 = address(0x3);
    address user2 = address(0x4);

    function setUp() public {
        token = new RWAToken("RWA Token", "RWA", 1000 ether, admin);
    }

    // ============ Initialization Tests ============
    function test_initialization() public {
        assertEq(token.name(), "RWA Token");
        assertEq(token.symbol(), "RWA");
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.balanceOf(admin), 1000 ether);
    }

    function test_roleSetup() public {
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(token.hasRole(token.MINTER_ROLE(), admin));
        assertTrue(token.hasRole(token.PAUSER_ROLE(), admin));
    }

    // ============ Minting Tests ============
    function test_mint_byMinter() public {
        vm.prank(admin);
        token.grantRole(token.MINTER_ROLE(), minter);

        vm.prank(minter);
        token.mint(user1, 100 ether);

        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.totalSupply(), 1100 ether);
    }

    function test_mint_revertIfNotMinter() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, 100 ether);
    }

    function test_mint_revertIfZeroAmount() public {
        vm.prank(admin);
        vm.expectRevert("Cannot mint zero");
        token.mint(user1, 0);
    }

    function test_mint_revertIfInvalidRecipient() public {
        vm.prank(admin);
        vm.expectRevert("Invalid recipient");
        token.mint(address(0), 100 ether);
    }

    // ============ Transfer Tests ============
    function test_transfer() public {
        vm.prank(admin);
        token.transfer(user1, 100 ether);

        assertEq(token.balanceOf(admin), 900 ether);
        assertEq(token.balanceOf(user1), 100 ether);
    }

    function test_transferFrom() public {
        vm.prank(admin);
        token.approve(user1, 100 ether);

        vm.prank(user1);
        token.transferFrom(admin, user2, 100 ether);

        assertEq(token.balanceOf(admin), 900 ether);
        assertEq(token.balanceOf(user2), 100 ether);
    }

    // ============ Pausing Tests ============
    function test_pause_byPauser() public {
        vm.prank(admin);
        token.pause();

        assertTrue(token.paused());
    }

    function test_pausedTransferRevert() public {
        vm.prank(admin);
        token.pause();

        vm.prank(admin);
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        token.transfer(user1, 100 ether);
    }

    function test_unpause_byAdmin() public {
        vm.prank(admin);
        token.pause();

        vm.prank(admin);
        token.unpause();

        assertFalse(token.paused());

        vm.prank(admin);
        token.transfer(user1, 100 ether);

        assertEq(token.balanceOf(user1), 100 ether);
    }

    // ============ Burning Tests ============
    function test_burn() public {
        vm.prank(admin);
        token.burn(100 ether);

        assertEq(token.totalSupply(), 900 ether);
        assertEq(token.balanceOf(admin), 900 ether);
    }

    function test_burnFrom() public {
        vm.prank(admin);
        token.approve(user1, 100 ether);

        vm.prank(user1);
        token.burnFrom(admin, 100 ether);

        assertEq(token.totalSupply(), 900 ether);
        assertEq(token.balanceOf(admin), 900 ether);
    }

    // ============ Permit Tests ============
    function test_permit() public {
        // TODO: Implement permit test with signature generation
    }
}
