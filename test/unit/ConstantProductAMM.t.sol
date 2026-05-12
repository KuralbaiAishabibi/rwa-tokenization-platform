// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../contracts/defi/ConstantProductAMM.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 1000000 ether);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract ConstantProductAMMTest is Test {
    ConstantProductAMM amm;
    MockERC20 token0;
    MockERC20 token1;

    address liquidity_provider = address(0x1);
    address trader = address(0x2);

    function setUp() public {
        token0 = new MockERC20("Token 0", "T0");
        token1 = new MockERC20("Token 1", "T1");

        amm = new ConstantProductAMM(address(token0), address(token1));

        // Setup balances
        token0.mint(liquidity_provider, 100 ether);
        token1.mint(liquidity_provider, 100 ether);
        token0.mint(trader, 50 ether);
        token1.mint(trader, 50 ether);
    }

    // ============ Initialization Tests ============
    function test_initialization() public {
        assertEq(amm.token0(), address(token0));
        assertEq(amm.token1(), address(token1));
        assertEq(amm.totalSupply(), 0);
    }

    // ============ Liquidity Tests ============
    function test_addLiquidity() public {
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);

        uint256 lpTokens = amm.addLiquidity(10 ether, 10 ether);

        assertGt(lpTokens, 0);
        assertEq(amm.reserve0(), 10 ether);
        assertEq(amm.reserve1(), 10 ether);
        assertEq(amm.balanceOf(liquidity_provider), lpTokens);

        vm.stopPrank();
    }

    function test_addLiquidityMultiple() public {
        // First provider
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        uint256 lp1 = amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        // Second provider with same ratio
        address provider2 = address(0x3);
        token0.mint(provider2, 100 ether);
        token1.mint(provider2, 100 ether);

        vm.startPrank(provider2);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        uint256 lp2 = amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        assertEq(lp1, lp2);
        assertEq(amm.totalSupply(), lp1 + lp2);
    }

    function test_removeLiquidity() public {
        // Add liquidity
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        uint256 lpTokens = amm.addLiquidity(10 ether, 10 ether);

        // Remove liquidity
        (uint256 amount0Out, uint256 amount1Out) = amm.removeLiquidity(lpTokens);

        assertEq(amount0Out, 10 ether);
        assertEq(amount1Out, 10 ether);
        assertEq(amm.balanceOf(liquidity_provider), 0);
        assertEq(amm.reserve0(), 0);
        assertEq(amm.reserve1(), 0);

        vm.stopPrank();
    }

    // ============ Swap Tests ============
    function test_swap0For1() public {
        // Setup liquidity
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        // Perform swap
        vm.startPrank(trader);
        token0.approve(address(amm), 50 ether);

        uint256 amountOut = amm.swap0For1(1 ether, 0);

        assertGt(amountOut, 0);
        assertLt(amountOut, 1 ether); // Loss due to AMM math and fee
        assertEq(token0.balanceOf(trader), 49 ether);
        assertEq(token1.balanceOf(trader), 50 ether + amountOut);

        vm.stopPrank();
    }

    function test_swap1For0() public {
        // Setup liquidity
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        // Perform swap
        vm.startPrank(trader);
        token1.approve(address(amm), 50 ether);

        uint256 amountOut = amm.swap1For0(1 ether, 0);

        assertGt(amountOut, 0);
        assertLt(amountOut, 1 ether);
        assertEq(token1.balanceOf(trader), 49 ether);
        assertEq(token0.balanceOf(trader), 50 ether + amountOut);

        vm.stopPrank();
    }

    function test_swap_slippageProtection() public {
        // Setup liquidity
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        // Try swap with unrealistic minimum
        vm.startPrank(trader);
        token0.approve(address(amm), 50 ether);

        vm.expectRevert("Excessive slippage");
        amm.swap0For1(1 ether, 10 ether); // Asking for 10 ether when ~0.99 available

        vm.stopPrank();
    }

    // ============ Invariant Tests ============
    function test_kInvariant() public {
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        uint256 kBefore = amm.k();

        vm.startPrank(trader);
        token0.approve(address(amm), 50 ether);
        amm.swap0For1(1 ether, 0);
        vm.stopPrank();

        uint256 kAfter = amm.k();

        assertGe(kAfter, kBefore); // k never decreases (except rounding)
    }

    // ============ View Functions ============
    function test_getPrice() public {
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        uint256 price0 = amm.getPrice0();
        uint256 price1 = amm.getPrice1();

        assertEq(price0, 1e18); // 1:1 ratio
        assertEq(price1, 1e18);
    }

    function test_getAmountOut() public {
        vm.startPrank(liquidity_provider);
        token0.approve(address(amm), 100 ether);
        token1.approve(address(amm), 100 ether);
        amm.addLiquidity(10 ether, 10 ether);
        vm.stopPrank();

        uint256 amountOut = amm.getAmountOut(1 ether, true);
        assertGt(amountOut, 0);
        assertLt(amountOut, 1 ether);
    }
}
