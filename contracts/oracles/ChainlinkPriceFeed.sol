// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title ChainlinkPriceFeed
 * @dev Integration with Chainlink oracle for price feeds
 * 
 * Features:
 * - Chainlink price feed integration
 * - Staleness check (prevents stale price usage)
 * - Decimal handling
 * - Oracle adapter pattern for abstraction
 */

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ChainlinkPriceFeed is AccessControl {
    // ============ Constants ============
    bytes32 public constant ORACLE_UPDATER = keccak256("ORACLE_UPDATER");
    uint256 public constant DEFAULT_STALENESS_THRESHOLD = 1 hours;

    // ============ State ============
    AggregatorV3Interface public aggregator;
    uint256 public stalenessThreshold;

    // ============ Events ============
    event AggregatorUpdated(address indexed newAggregator);
    event StalenessThresholdUpdated(uint256 newThreshold);
    event PriceFetched(uint256 price, uint256 timestamp, uint80 roundId);

    // ============ Constructor ============
    /**
     * @notice Initialize price feed
     * @param _aggregator Chainlink aggregator address
     * @param admin Admin address
     */
    constructor(address _aggregator, address admin) {
        require(_aggregator != address(0), "Invalid aggregator");
        require(admin != address(0), "Invalid admin");

        aggregator = AggregatorV3Interface(_aggregator);
        stalenessThreshold = DEFAULT_STALENESS_THRESHOLD;

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ORACLE_UPDATER, admin);
    }

    // ============ Price Feed Functions ============
    /**
     * @notice Get latest price from Chainlink
     * @return price Latest price
     * @return timestamp Price update timestamp
     * @return roundId Round ID
     */
    function getLatestPrice()
        external
        view
        returns (
            uint256 price,
            uint256 timestamp,
            uint80 roundId
        )
    {
        (roundId, int256 rawPrice, , timestamp, ) = aggregator
            .latestRoundData();

        // CHECKS
        require(rawPrice > 0, "Invalid price");
        require(
            block.timestamp - timestamp < stalenessThreshold,
            "Stale price feed"
        );

        price = uint256(rawPrice);
        emit PriceFetched(price, timestamp, roundId);
    }

    /**
     * @notice Get price for specific round
     * @param roundId Round ID to query
     * @return price Price at round
     * @return timestamp Timestamp of price
     */
    function getPriceForRound(uint80 roundId)
        external
        view
        returns (uint256 price, uint256 timestamp)
    {
        (, int256 rawPrice, , timestamp, ) = aggregator.getRoundData(roundId);

        require(rawPrice > 0, "Invalid price");
        require(
            block.timestamp - timestamp < stalenessThreshold,
            "Stale price feed"
        );

        price = uint256(rawPrice);
    }

    /**
     * @notice Get current price with fallback handling
     * @return price Current price or revert if unavailable
     */
    function safeGetLatestPrice() external view returns (uint256) {
        try this.getLatestPrice() returns (
            uint256 price,
            uint256,
            uint80
        ) {
            return price;
        } catch {
            revert("Price feed unavailable");
        }
    }

    // ============ Admin Functions ============
    /**
     * @notice Update aggregator address
     * @param newAggregator New aggregator address
     */
    function setAggregator(address newAggregator)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newAggregator != address(0), "Invalid aggregator");
        aggregator = AggregatorV3Interface(newAggregator);
        emit AggregatorUpdated(newAggregator);
    }

    /**
     * @notice Update staleness threshold
     * @param newThreshold New threshold in seconds
     */
    function setStalenessThreshold(uint256 newThreshold)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(newThreshold > 0, "Invalid threshold");
        stalenessThreshold = newThreshold;
        emit StalenessThresholdUpdated(newThreshold);
    }

    // ============ View Functions ============
    /**
     * @notice Get feed decimals
     * @return decimals Number of decimals
     */
    function getDecimals() external view returns (uint8) {
        return aggregator.decimals();
    }

    /**
     * @notice Check if price is stale
     * @return isStale True if price is stale
     */
    function isPriceStale() external view returns (bool) {
        (, , , uint256 updatedAt, ) = aggregator.latestRoundData();
        return (block.timestamp - updatedAt) >= stalenessThreshold;
    }
}
