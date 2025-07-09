# Overview of Droplinked Contracts

## 1. Contracts Overview

## A. `Shop.sol` (Contract: `DropShop`)

- **Purpose:** Acts as a decentralized marketplace with product registration, affiliate management, and NFT minting.
- **Imports:**
  - OpenZeppelin modules for access control and ERC token interfaces.
  - Interfaces for external dependency handling (`IDIP1`, `SignatureVerifier`).
- **Core Features:**
  - Product management: Registration, unregistration, affiliate linking, and minting.
  - NFT handling: Integration for ERC721 and ERC1155 standards.
  - Fee management: Supports interactions with deployer contracts for setting and claiming fees.
- **Functions:**
  - **Product Management:**
    - `mintAndRegister`, `registerProduct`: Mint and register products on the platform.
    - `unregisterProduct`: Remove products.
  - **Affiliate System:**
    - `requestAffiliate`, `approveRequest`, `disapproveRequest`: Handle affiliate requests.
  - **NFT Interaction:**
    - ERC721 and ERC1155 receiver functions.
  - **Shop Metadata:**
    - Functions like `getShopName`, `getShopAddress` provide shop details.
  - **Signature Verification:**
    - `claimPurchase` ensures secure purchase transactions.

## B. `SignatureVerifier.sol`

- **Purpose:** Validates cryptographic signatures for secure purchases.
- **Core Features:**
  - Verifies integrity and authenticity of purchase requests.
  - Functions like `verifyPurchase` use `getMessageHash` and `getEthSignedMessageHash` for Ethereum-compatible signing.
- **Functions:**
  - `verifyPurchase`: Main function to validate purchase signatures.
  - `getMessageHash`, `getEthSignedMessageHash`: Utility functions for hashing and Ethereum signing format.

## C. `IDropShop.sol` (Interface)

- **Purpose:** Defines the required functions for a compliant marketplace contract.
- **Core Features:**
  - Metadata retrieval (`_shopInfo`).
  - Product management and affiliate system (`registerProduct`, `requestAffiliate`).
  - Ownership and fee utilities.
- **Functions:**
  - **Shop Details:** `getShopName`, `getShopOwner`.
  - **Product Details:** `getProduct`, `getProductId`.

---

## 2. Functions

### Key Functions from `DropShop`

| **Function Name**               | **Inputs**                               | **Outputs**                     | **Visibility**  | **Description**                                      |
|----------------------------------|------------------------------------------|----------------------------------|-----------------|------------------------------------------------------|
| `mintAndRegister`                | `RecordData`                             | `uint256 productId`             | `public`        | Mints and registers a product.                     |
| `registerProduct`                | `uint256 _tokenId`, `address _nftAddress`, `uint256 _affiliatePercentage` , `NFTType`, `ProductType` | `uint256` | `public` | Registers a product with its details.              |
| `requestAffiliate`               | `uint256 productId`                      | `uint256 requestId`             | `external`      | Requests an affiliate link for a product.          |
| `approveRequest`                 | `uint256 requestId`                      | None                            | `external`      | Approves an affiliate request.                     |
| `claimPurchase`                  | `address manager`, `bytes signature`, `PurchaseSignature` | None | `external` | Validates and processes a purchase using a signature. |

### Key Functions from `SignatureVerifier`

| **Function Name**               | **Inputs**                               | **Outputs**                     | **Visibility**  | **Description**                                      |
|----------------------------------|------------------------------------------|----------------------------------|-----------------|------------------------------------------------------|
| `verifyPurchase`                 | `address signer`, `bytes signature`, `PurchaseSignature` | `bool` | `public` | Validates a purchase signature.                    |
| `getMessageHash`                 | `PurchaseSignature`                      | `bytes32`                       | `public`        | Returns a hash of purchase data for signing.        |

### Key Functions from `IDropShop`

| **Function Name**               | **Inputs**                               | **Outputs**                     | **Visibility**  | **Description**                                      |
|----------------------------------|------------------------------------------|----------------------------------|-----------------|------------------------------------------------------|
| `_shopInfo`                      | None                                     | Shop metadata                   | `external`      | Returns shop information.                           |
| `getProduct`                     | `uint256 productId`                      | `Product`                       | `external`      | Fetches details of a product by ID.                 |

---

## 4. Requirements and Interaction Flow

1. **Deployment:**
   - Deploy `DropShop` with the necessary parameters and dependencies through `DropShopDeployer`.
2. **Registration:**
   - Add products using `mintAndRegister` or `registerProduct`.
3. **Affiliation:**
   - Submit requests with `requestAffiliate`, and approve them via `approveRequest`.
4. **Purchase Handling:**
   - Verify transactions using the `claimPurchase` and `verifyPurchase` functions.

---
