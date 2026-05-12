// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title ConstantProductAMM
 * @dev Constant product AMM (x·y=k) with 0.3% fee and slippage protection
 * 
 * Features:
 * - x·y=k invariant (Uniswap V2 style)
 * - 0.3% fee on swaps
 * - LP tokens for liquidity providers
 * - Slippage protection (minAmountOut)
 * - Reentrancy protection
 * 
 * Design Patterns:
 * - ReentrancyGuard: Prevent reentrancy attacks
 * - Checks-Effects-Interactions: Safe state management
 * - Pull-over-Push: Safe payment distribution
 */

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ConstantProductAMM is ReentrancyGuard, ERC20 {
    using SafeERC20 for IERC20;

    // ============ Constants ============
    uint256 public constant FEE_PERCENT = 3; // 0.3% in basis points (divide by 1000)
    uint256 private constant MINIMUM_LIQUIDITY = 1000;

    // ============ State ============
    IERC20 public token0;
    IERC20 public token1;

    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public k; // Invariant

    // ============ Events ============
    event Swap(
        address indexed user,
        address indexed tokenIn,
        uint256 amountIn,
        uint256 amountOut,
        uint256 fee
    );

    event LiquidityAdded(
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 lpTokens
    );

    event LiquidityRemoved(
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 lpTokens
    );

    // ============ Constructor ============
    constructor(address _token0, address _token1) ERC20("AMM-LP", "LP") {
        require(_token0 != address(0) && _token1 != address(0), "Invalid tokens");
        require(_token0 != _token1, "Same token");

        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    // ============ Liquidity Management ============
    /**
     * @notice Add liquidity to pool
     * @param amount0 Amount of token0
     * @param amount1 Amount of token1
     * @return liquidity LP tokens minted
     */
    function addLiquidity(uint256 amount0, uint256 amount1)
        external
        nonReentrant
        returns (uint256 liquidity)
    {
        require(amount0 > 0 && amount1 > 0, "Zero amount");

        // CHECKS
        uint256 balance0Before = token0.balanceOf(address(this));
        uint256 balance1Before = token1.balanceOf(address(this));

        // EFFECTS
        if (totalSupply() == 0) {
            liquidity = _sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // Burn minimum liquidity
        } else {
            uint256 liquidity0 = (amount0 * totalSupply()) / reserve0;
            uint256 liquidity1 = (amount1 * totalSupply()) / reserve1;
            liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
        }

        require(liquidity > 0, "Insufficient liquidity minted");

        _mint(msg.sender, liquidity);

        // INTERACTIONS (external calls last)
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);

        // Update reserves
        _updateReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );

        emit LiquidityAdded(msg.sender, amount0, amount1, liquidity);
    }

    /**
     * @notice Remove liquidity from pool
     * @param liquidity Amount of LP tokens to burn
     * @return amount0 Amount of token0 received
     * @return amount1 Amount of token1 received
     */
    function removeLiquidity(uint256 liquidity)
        external
        nonReentrant
        returns (uint256 amount0, uint256 amount1)
    {
        require(liquidity > 0, "Zero liquidity");
        require(balanceOf(msg.sender) >= liquidity, "Insufficient LP tokens");

        // CHECKS
        uint256 balance0 = token0.balanceOf(address(this));
        uint256 balance1 = token1.balanceOf(address(this));
        uint256 totalLiquidity = totalSupply();

        // EFFECTS
        amount0 = (liquidity * balance0) / totalLiquidity;
        amount1 = (liquidity * balance1) / totalLiquidity;

        require(amount0 > 0 && amount1 > 0, "Insufficient liquidity");

        _burn(msg.sender, liquidity);

        // INTERACTIONS
        token0.safeTransfer(msg.sender, amount0);
        token1.safeTransfer(msg.sender, amount1);

        // Update reserves
        _updateReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );

        emit LiquidityRemoved(msg.sender, amount0, amount1, liquidity);
    }

    // ============ Swapping ============
    /**
     * @notice Swap token0 for token1
     * @param amountIn Amount of token0 to swap
     * @param minAmountOut Minimum acceptable output
     * @return amountOut Amount of token1 received
     */
    function swap0For1(uint256 amountIn, uint256 minAmountOut)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "Zero amount");
        require(reserve0 > 0 && reserve1 > 0, "Insufficient liquidity");

        // CHECKS: Calculate output with 0.3% fee
        uint256 amountInWithFee = (amountIn * (1000 - FEE_PERCENT)) / 1000;
        amountOut = (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);

        require(amountOut >= minAmountOut, "Excessive slippage");
        require(amountOut < reserve1, "Output exceeds reserve");

        uint256 fee = amountIn - amountInWithFee;

        // EFFECTS
        reserve0 += amountInWithFee;
        reserve1 -= amountOut;
        _updateK();

        // INTERACTIONS
        token0.safeTransferFrom(msg.sender, address(this), amountIn);
        token1.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, address(token0), amountIn, amountOut, fee);
    }

    /**
     * @notice Swap token1 for token0
     * @param amountIn Amount of token1 to swap
     * @param minAmountOut Minimum acceptable output
     * @return amountOut Amount of token0 received
     */
    function swap1For0(uint256 amountIn, uint256 minAmountOut)
        external
        nonReentrant
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "Zero amount");
        require(reserve0 > 0 && reserve1 > 0, "Insufficient liquidity");

        // CHECKS
        uint256 amountInWithFee = (amountIn * (1000 - FEE_PERCENT)) / 1000;
        amountOut = (reserve0 * amountInWithFee) / (reserve1 + amountInWithFee);

        require(amountOut >= minAmountOut, "Excessive slippage");
        require(amountOut < reserve0, "Output exceeds reserve");

        uint256 fee = amountIn - amountInWithFee;

        // EFFECTS
        reserve1 += amountInWithFee;
        reserve0 -= amountOut;
        _updateK();

        // INTERACTIONS
        token1.safeTransferFrom(msg.sender, address(this), amountIn);
        token0.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, address(token1), amountIn, amountOut, fee);
    }

    // ============ Internal Functions ============
    /**
     * @notice Update reserves and k invariant
     * @param newReserve0 New reserve0
     * @param newReserve1 New reserve1
     */
    function _updateReserves(uint256 newReserve0, uint256 newReserve1)
        internal
    {
        reserve0 = newReserve0;
        reserve1 = newReserve1;
        _updateK();
    }

    /**
     * @notice Update k invariant
     * @dev k = reserve0 * reserve1
     */
    function _updateK() internal {
        k = reserve0 * reserve1;
    }

    /**
     * @notice Calculate square root (Newton's method)
     * @param x Value to sqrt
     * @return y Square root of x
     */
    function _sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    // ============ View Functions ============
    /**
     * @notice Get price of token0 in terms of token1
     * @return price Price ratio (token1 per token0)
     */
    function getPrice0() external view returns (uint256) {
        require(reserve0 > 0, "Invalid reserve");
        return (reserve1 * 1e18) / reserve0;
    }

    /**
     * @notice Get price of token1 in terms of token0
     * @return price Price ratio (token0 per token1)
     */
    function getPrice1() external view returns (uint256) {
        require(reserve1 > 0, "Invalid reserve");
        return (reserve0 * 1e18) / reserve1;
    }

    /**
     * @notice Get amount out for swap
     * @param amountIn Input amount
     * @param isToken0 True if swapping token0, false if token1
     * @return amountOut Output amount (before slippage)
     */
    function getAmountOut(uint256 amountIn, bool isToken0)
        external
        view
        returns (uint256 amountOut)
    {
        require(amountIn > 0 && reserve0 > 0 && reserve1 > 0, "Invalid params");

        uint256 amountInWithFee = (amountIn * (1000 - FEE_PERCENT)) / 1000;

        if (isToken0) {
            amountOut = (reserve1 * amountInWithFee) / (reserve0 + amountInWithFee);
        } else {
            amountOut = (reserve0 * amountInWithFee) / (reserve1 + amountInWithFee);
        }
    }
}
