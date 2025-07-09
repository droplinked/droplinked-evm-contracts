# Droplinked Technical Documentation

## Overview

Droplinked is a decentralized e-commerce platform built on EVM-compatible blockchains, enabling seamless product management, affiliate marketing, and digital asset transactions. The platform consists of several smart contracts that handle various aspects of the ecosystem, including token management, shop operations, payment processing, and token distribution.

## Contract Architecture

The system comprises several key components working together:

1. **Shop Contract**: Core contract managing product listings, affiliate relationships, and purchasing.
2. **DropERC1155/DropERC721**: NFT contracts for digital products and ownership representation.
3. **Deployer Contract**: Factory contract for deploying shop instances and associated NFT contracts.
4. **Payment Proxy**: Handles payment processing with price feed integration.
5. **Airdrop Utility**: Facilitates token distribution across multiple recipients.

## Core Components

### Shop Contract (`DropShop.sol`)

This contract is the central hub for a merchant's storefront, handling product management, affiliate requests, and claim processing.

#### Key Features

- **Product Registration**: Merchants can register products as ERC721 or ERC1155 tokens.
- **Affiliate System**: Publishers can request to become affiliates for specific products.
- **Purchase Verification**: Signature-based verification for product purchases.
- **Access Control**: Role-based permissions with owner and manager capabilities.

#### Main Functions

- `registerProduct()`: Register a new product in the shop.
- `mintAndRegister()`: Mint a new NFT token and register it as a product in one transaction.
- `requestAffiliate()`: Allow users to request affiliate status for a product.
- `approveRequest()`: Approve affiliate requests.
- `claimPurchase()`: Process purchase claims with signature verification.

### NFT Tokens

#### DropERC1155 (`DropERC1155.sol`)

A customized ERC1155 implementation for representing multi-instance products and digital assets.

#### Main Features

- **Minting**: Create new tokens with royalty information.
- **Royalty Tracking**: Record creator royalties for each token.
- **Managed Approvals**: Automatic approval management for the shop contract.
- **Metadata Management**: URI tracking for token metadata.

#### Key Functions

- `mint()`: Create a new token or add supply to an existing token.
- `getIssuer()`: Retrieve the original issuer and royalty information.
- `droplinkedSafeBatchTransferFrom()`: Optimized batch transfer function.

### Payment System

#### Payment Proxy (`PaymentProxy.sol`)

Handles payment processing with support for native tokens, ERC20 tokens, and price feed integration.

#### Key Features

- **Chainlink Integration**: Uses Chainlink price feeds for currency conversion.
- **Multi-currency Support**: Handles payments in native tokens and ERC20 tokens.
- **Heartbeat Validation**: Ensures price data is recent and valid.

#### Main Functions

- `droplinkedPurchase()`: Process a purchase with various payment methods.
- `getLatestPrice()`: Fetch current price data from Chainlink.

### Deployment System

#### Shop Deployer (`shopDeployer.sol`)

A factory contract that creates new shop instances and associated NFT contracts.

#### Key Features

- **CREATE2 Deployment**: Uses CREATE2 for deterministic address generation.
- **Fee Management**: Centralizes fee settings for all shops.
- **Shop Registry**: Maintains a record of all deployed shops.

#### Main Functions

- `deployShop()`: Deploy a new shop with associated NFT contract.
- `setDroplinkedFee()`: Update the platform fee.

### Utility Contracts

#### Bulk Token Distributor (`airdrop.sol`)

A utility contract for distributing tokens (ERC20, ERC721, ERC1155) to multiple recipients in a gas-efficient manner.

#### Key Features

- **Multi-token Support**: Works with ERC20, ERC721, and ERC1155 tokens.
- **Batch Processing**: Efficiently processes multiple transfers in a single transaction.

#### Main Functions

- `distributeERC20()`: Send ERC20 tokens to multiple recipients.
- `distributeERC721()`: Send ERC721 tokens to multiple recipients.
- `distributeERC1155()`: Send ERC1155 tokens to multiple recipients.

## Data Structures

The system uses several key data structures to represent entities:

### Product

Represents a product available in a shop:

```solidity
struct Product {
    uint256 tokenId;
    address nftAddress;
    NFTType nftType;
    ProductType productType;
    uint256 affiliatePercentage;
}
```

### AffiliateRequest

Represents a request to become an affiliate for a product:

```solidity
struct AffiliateRequest {
    address publisher;
    uint256 productId;
    bool isConfirmed;
}
```

### ShopInfo

Contains information about a shop:

```solidity
struct ShopInfo {
    string shopName;
    string shopAddress;
    string shopLogo;
    string shopDescription;
    address shopOwner;
}
```

### Purchase Data

Structures related to purchases:

```solidity
struct PurchasedItem {
    uint256 amount;
    uint256 productId;
    uint256 nullifier;
}

struct PurchaseSignature {
    PurchasedItem[] cart;
    address shop;
}
```

## Workflow Examples

### Creating a Shop

1. Call `deployShop()` on the Deployer contract
2. The deployer creates a new Shop instance and associated NFT contract
3. The deployer registers the shop and configures initial settings

### Listing a Product

1. Merchant calls `mintAndRegister()` on their Shop contract
2. An NFT is minted to represent the product
3. The product is registered in the shop's inventory

### Affiliate Process

1. Publisher calls `requestAffiliate()` for a product
2. Merchant calls `approveRequest()` to approve the affiliate
3. The affiliate can now promote the product and earn commissions

### Purchase Process

1. Customer initiates purchase off-chain
2. Backend creates a signed purchase message
3. Customer or backend calls `claimPurchase()` with the signature
4. Upon verification, the product NFT is transferred to the customer

## Security Considerations

- **Signature Verification**: The system relies on cryptographic signatures for purchase verification
- **Access Control**: Role-based permissions restrict sensitive operations
- **Price Feed Validation**: Heartbeat checks ensure price data is current
- **Nullifier Pattern**: Prevents double-claiming of purchases

## Integration Points

- **Frontend Applications**: Interact with the contracts for product management and purchases
- **Chainlink Price Feeds**: External data source for currency conversion
- **Metadata Storage**: External systems store product metadata referenced by token URIs

## Upgrade Paths

The Deployer contract uses the OpenZeppelin Upgradeable pattern, allowing for future upgrades to functionality while preserving deployed shops and data.
