## 1. Contract Overview

### Contract: `DroplinkedPaymentProxy`
- **Purpose:** Provides a payment proxy system with Chainlink Price Feeds for processing purchases in different currencies, including native tokens and ERC20 tokens. It also handles affiliate payments and tracks purchase details.
- **Imports:**
  - OpenZeppelin's `IERC20` for token transfers and `Ownable` for ownership control.
  - External structs from a `structs.sol` file for data organization.
- **Core Features:**
  - Handles purchases with multiple payment methods.
  - Converts payment amounts to native token values using Chainlink Price Feeds.
  - Supports affiliate tracking and memo logging for purchases.

---

## 2. Events

| **Event Name**        | **Parameters**          | **Description**                                         |
|------------------------|-------------------------|---------------------------------------------------------|
| `HeartBeatChanged`     | `uint newHeartBeat`     | Emitted when the heartbeat interval is updated.         |
| `ProductPurchased`     | `string memo`          | Emitted when a product is successfully purchased.       |

---

## 3. Functions

### Key Functions
| **Function Name**         | **Inputs**                              | **Outputs**                     | **Visibility**  | **Description**                                      |
|----------------------------|------------------------------------------|----------------------------------|-----------------|------------------------------------------------------|
| `changeHeartBeat`          | `_heartBeat: uint`                      | None                            | `external`      | Allows the owner to update the heartbeat interval.   |
| `getLatestPrice`           | `_roundId: uint80`                      | `(uint, uint)`                  | `internal`      | Fetches the latest price and ratio from Chainlink.   |
| `toNativePrice`            | `value: uint`, `ratio: uint`              | `uint`                          | `private`       | Converts a value to native token price.              |
| `transferTBDValues`        | `tbdValues: uint[]`, `tbdReceivers: address[]`, `ratio: uint`, `currency: address` | `uint`          | `private`       | Transfers specified values to recipients.            |
| `droplinkedPurchase`       | `tbdValues: uint[]`, `tbdReceivers: address[]`, `currency: address`, `roundId: uint80`, `memo: string` | None | `public payable` | Handles the purchase logic, memo logging, and payments. |

---

## 4. Requirements and Interaction Flow

1. **Deployment:**
   - Deploy the `DroplinkedPaymentProxy` contract with necessary parameters.
2. **Configuration:**
   - Update the heartbeat interval using `changeHeartBeat` as needed.
3. **Purchase Handling:**
   - Use `droplinkedPurchase` to process purchases, specifying payment values, receivers, and a purchase memo.
4. **Price Conversion:**
   - Internally fetch and convert prices using `getLatestPrice` and `toNativePrice`.

---

## 5. Additional Notes
- **Memo Tracking:** The `ProductPurchased` event includes a purchase memo for tracking purposes.
- **Affiliate Support:** `droplinkedPurchase` can manage affiliate payouts through the `tbdReceivers` parameter.

