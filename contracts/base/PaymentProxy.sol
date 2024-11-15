// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../structs/structs.sol";

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

    /// @notice Time window for considering price data valid.
    uint public heartBeat;

    /// @notice Emitted when heartBeat is changed.
    event HeartBeatChanged(uint newHeartBeat);

    AggregatorV3Interface internal priceFeed;

    event ProductPurchased(string memo);

    constructor(
        uint256 _heartBeat,
        address _chainLinkProvider
    ) Ownable(msg.sender) {
        heartBeat = _heartBeat;
        priceFeed = AggregatorV3Interface(_chainLinkProvider);
    }

    /// @param _heartBeat The new heartBeat to set.
    function changeHeartBeat(uint _heartBeat) external onlyOwner {
        heartBeat = _heartBeat;
        emit HeartBeatChanged(_heartBeat);
    }

    /**
     * @dev Retrieves the latest price and its timestamp from the Chainlink Oracle.
     * @param roundId The round ID to fetch the price from.
     * @return price The price of the asset.
     * @return timestamp The timestamp when the price was recorded.
     */
    function getLatestPrice(uint80 roundId) internal view returns (uint, uint) {
        (, int256 price, , uint256 timestamp, ) = priceFeed.getRoundData(
            roundId
        );
        if (price == 0) {
            revert(
                string(
                    abi.encodePacked(
                        "Invalid price or outdated timestamp. Price timestamp: ",
                        timestamp,
                        ", Current timestamp: ",
                        block.timestamp
                    )
                )
            );
        }
        return (uint(price), timestamp);
    }

    /**
     * @dev Converts the given value to the native price using the provided ratio.
     * @param value The value to convert.
     * @param ratio The conversion ratio.
     * @return The converted value.
     */
    function toNativePrice(uint value, uint ratio) private pure returns (uint) {
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
        uint[] memory tbdValues,
        address[] memory tbdReceivers,
        uint ratio,
        address currency
    ) private returns (uint) {
        uint currentValue = 0;
        for (uint i = 0; i < tbdReceivers.length; i++) {
            uint value = currency == address(0)
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
        uint[] memory tbdValues,
        address[] memory tbdReceivers,
        address currency,
        uint80 roundId,
        string memory memo
    ) public payable {
        uint ratio = 0;
        if (currency == address(0)) {
            uint256 timestamp;
            (ratio, timestamp) = getLatestPrice(roundId);
            if (ratio == 0) revert("Chainlink Contract not found");
            if (
                block.timestamp > timestamp &&
                block.timestamp - timestamp > 2 * heartBeat
            ) revert oldPrice(timestamp, block.timestamp);
        }
        transferTBDValues(tbdValues, tbdReceivers, ratio, currency);
        emit ProductPurchased(memo);
    }
}
