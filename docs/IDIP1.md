## 1. Contract Overview

### Interface: `IDIP1`
- **Purpose:** A blueprint for contracts managing decentralized shops, product registration, and affiliate systems.
- **Imports:**
  - External structs from a `structs.sol` file for structured data management.
- **Core Features:**
  - Product registration and unregistration.
  - Affiliate request management (creation, approval, and disapproval).
  - Shop metadata retrieval.
  - Batch operations for product minting and registration.

---

## 2. Events

| **Event Name**                 | **Parameters**                                            | **Description**                                     |
|---------------------------------|----------------------------------------------------------|-----------------------------------------------------|
| `ProductRegistered`            | `uint256 productId`, `uint256 amount`, `address owner`, `string uri` | Emitted when a product is registered.             |
| `ProductUnregistered`          | `uint256 productId`, `address owner`                       | Emitted when a product is unregistered.            |
| `AffiliateRequested`           | `uint256 requestId`, `uint256 productId`, `address requester` | Emitted when an affiliate request is created.      |
| `AffiliateRequestApproved`     | `uint256 requestId`, `address approver`                    | Emitted when an affiliate request is approved.     |
| `AffiliateRequestDisapproved`  | `uint256 requestId`, `address disapprover`                 | Emitted when an affiliate request is disapproved.  |
| `ProductClaimed`               | `uint256 productId`, `address claimer`, `uint256 amount`     | Emitted when a product is claimed.                 |

---

## 3. Functions

### Key Functions
| **Function Name**              | **Inputs**                              | **Outputs**                     | **Visibility**  | **Description**                                      |
|---------------------------------|------------------------------------------|----------------------------------|-----------------|------------------------------------------------------|
| `getShopName`                   | None                                     | `string`                        | `external`      | Returns the name of the shop.                       |
| `getShopAddress`                | None                                     | `string`                        | `external`      | Returns the address of the shop.                    |
| `getShopOwner`                  | None                                     | `address`                       | `external`      | Returns the shop owner's address.                   |
| `getShopLogo`                   | None                                     | `string`                        | `external`      | Returns the logo of the shop.                       |
| `getShopDescription`            | None                                     | `string`                        | `external`      | Returns the shop's description.                     |
| `mintAndRegister`               | `RecordData mintData`                   | `uint256 productId`             | `external`      | Mints and registers a single product.               |
| `mintAndRegisterBatch`          | `RecordData[] recordData`               | None                            | `external`      | Mints and registers multiple products in a batch.   |
| `getProduct`                    | `uint256 productId`                     | `Product`                       | `external`      | Fetches details of a product by ID.                 |
| `getProductCount`               | None                                     | `uint256`                       | `external`      | Returns the total count of registered products.     |
| `registerProduct`               | `_tokenId`, `_nftAddress`, `_affiliatePercentage`, `NFTType`, `ProductType` | `uint256` | `external` | Registers a product with its details.              |
| `unregisterProduct`             | `uint256 productId`                     | None                            | `external`      | Unregisters a product by ID.                        |
| `requestAffiliate`              | `uint256 productId`                     | `uint256 requestId`             | `external`      | Requests an affiliate link for a product.           |
| `approveRequest`                | `uint256 requestId`                     | None                            | `external`      | Approves an affiliate request.                      |
| `disapproveRequest`             | `uint256 requestId`                     | None                            | `external`      | Disapproves an affiliate request.                   |
| `getAffiliate`                  | `uint256 requestId`                     | `AffiliateRequest`              | `external`      | Fetches details of an affiliate request.            |
| `getAffiliateRequestCount`      | None                                     | `uint256`                       | `external`      | Returns the total count of affiliate requests.      |

---

## 4. Requirements and Interaction Flow

1. **Shop Metadata:**
   - Retrieve shop details like name, address, logo, and owner using functions like `getShopName`, `getShopAddress`.
2. **Product Management:**
   - Register products with `registerProduct` or `mintAndRegister`.
   - Unregister products using `unregisterProduct`.
3. **Affiliate Management:**
   - Submit affiliate requests via `requestAffiliate`.
   - Approve or disapprove requests using `approveRequest` and `disapproveRequest`.
4. **Batch Operations:**
   - Use `mintAndRegisterBatch` for bulk product registration and minting.

---
