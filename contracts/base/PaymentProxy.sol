// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../structs/Structs.sol";

interface AggregatorV3Interface {
    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

/**
 * @title Droplinked Payment Proxy
 * @dev This contract provides a payment proxy system with chainlink price feeds for purchasing products.
 * It supports handling purchases with different payment methods and affiliate tracking.
 */
contract DroplinkedPaymentProxy is Ownable {
    /// @dev Error for reporting outdated price data.
    error oldPrice(uint256 priceTimestamp, uint256 currentTimestamp);

    /// @dev Error for reporting invalid or stale price data.
    error InvalidPriceOrStale(
        int256 price,
        uint256 priceTimestamp,
        uint256 currentTimestamp
    );

    /// @notice Time window for considering price data valid.
    uint256 public heartbeat;

    /// @notice Emitted when heartbeat is changed.
    event HeartbeatChanged(uint256 newHeartbeat);

    AggregatorV3Interface internal immutable priceFeed;

    event ProductPurchased(string memo);

    constructor(
        uint256 heartbeat_,
        address chainLinkProvider_
    ) Ownable(msg.sender) {
        heartbeat = heartbeat_;
        priceFeed = AggregatorV3Interface(chainLinkProvider_);
    }

    /// @param heartbeat_ The new heartbeat to set.
    function changeHeartbeat(uint256 heartbeat_) external onlyOwner {
        heartbeat = heartbeat_;
        emit HeartbeatChanged(heartbeat_);
    }

    /**
     * @dev Retrieves the latest price and its timestamp from the Chainlink Oracle.
     * @param roundId The round ID to fetch the price from.
     * @return price The price of the asset.
     * @return timestamp The timestamp when the price was recorded.
     */
    function getLatestPrice(
        uint80 roundId
    ) internal view returns (uint256, uint256) {
        (, int256 price, , uint256 timestamp, ) = priceFeed.getRoundData(
            roundId
        );
        if (price <= 0) {
            revert InvalidPriceOrStale(price, timestamp, block.timestamp);
        }
        return (uint256(price), timestamp);
    }

    /**
     * @dev Converts the given value to the native price using the provided ratio.
     * @param value The value to convert.
     * @param ratio The conversion ratio.
     * @return The converted value.
     */
    function toNativePrice(
        uint256 value,
        uint256 ratio
    ) private pure returns (uint256) {
        return (1e24 * value) / ratio;
    }

    /**
     * @dev Handles the transfer of value-based debts (TBD) to the specified recipients.
     * @param tbdValues The values to transfer.
     * @param tbdReceivers The recipients of the values.
     * @param ratio The price ratio for conversion if needed.
     * @param currency The currency in which the values are denominated.
     * @return The total value transferred.
     */
    function transferTBDValues(
        uint256[] memory tbdValues,
        address[] memory tbdReceivers,
        uint256 ratio,
        address currency
    ) private returns (uint256) {
        uint256 currentValue = 0;
        for (uint256 i = 0; i < tbdReceivers.length; i++) {
            uint256 value = currency == address(0)
                ? toNativePrice(tbdValues[i], ratio)
                : tbdValues[i];
            if (currency == address(1)) value = tbdValues[i];
            currentValue += value;
            if (currency != address(0) && currency != address(1)) {
                require(
                    IERC20(currency).transferFrom(
                        msg.sender,
                        tbdReceivers[i],
                        value
                    ),
                    "transferFrom failed"
                );
            } else {
                payable(tbdReceivers[i]).transfer(value);
            }
        }
        return currentValue;
    }

    /**
     * @dev Processes a batch of purchases, transferring the required funds and making the product purchase calls.
     * @param tbdValues Values of products to be transferred.
     * @param tbdReceivers Receivers of the payments.
     * @param currency The currency used for the purchase.
     * @param roundId The Chainlink round ID for price data.
     */
    function droplinkedPurchase(
        uint256[] memory tbdValues,
        address[] memory tbdReceivers,
        address currency,
        uint80 roundId,
        string memory memo
    ) public payable {
        uint256 ratio = 0;
        if (currency == address(0)) {
            uint256 timestamp;
            (ratio, timestamp) = getLatestPrice(roundId);
            if (ratio == 0 || timestamp > block.timestamp) {
                revert InvalidPriceOrStale(
                    int256(ratio),
                    timestamp,
                    block.timestamp
                );
            }
            if (
                block.timestamp > timestamp &&
                block.timestamp - timestamp > 2 * heartbeat
            ) revert oldPrice(timestamp, block.timestamp);
        }
        emit ProductPurchased(memo);
        transferTBDValues(tbdValues, tbdReceivers, ratio, currency);
    }
}
