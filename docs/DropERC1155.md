# Droplinked Token (ERC1155) Documentation

---

## 1. General Requirements
- **Purpose:** Implements a token contract based on the ERC1155 standard, with extensions for minting, fee management, and operator control.
- **Solidity Version:** Compatible with Solidity `^0.8.20`.
- **Features Required:**
  - ERC1155 compliance for handling multiple token types.
  - Operator and minter roles for controlled minting and token transfers.
  - Fee management for handling transactional fees.

---

## 2. Contract Overview

### Contract: `DroplinkedToken`
- **Purpose:** Extends the ERC1155 standard to include functionality for controlled minting, fee management, and multi-address token transfers.
- **Imports:**
  - OpenZeppelin's `ERC1155` for token standard implementation.
  - `Ownable` for ownership control.
  - External `structs.sol` for handling structured data like issuers.
- **Core Features:**
  - Minting of new tokens with URI and royalty support.
  - Management of transactional fees and operator permissions.
  - Enhanced batch transfer functionality, including multi-recipient transfers.

---

## 3. Events

| **Event Name**           | **Parameters**                                                | **Description**                                    |
|---------------------------|--------------------------------------------------------------|----------------------------------------------------|
| `MintEvent`               | `uint tokenId`, `address recipient`, `uint amount`, `string uri`   | Emitted when a token is minted.                   |
| `ManageWalletUpdated`     | `address newManagedWallet`                                   | Emitted when the managed wallet is updated.       |
| `FeeUpdated`              | `uint newFee`                                               | Emitted when the transaction fee is updated.      |

---

## 4. Functions

### Key Functions
| **Function Name**            | **Inputs**                                           | **Outputs**              | **Visibility**   | **Description**                                   |
|-------------------------------|-----------------------------------------------------|--------------------------|------------------|---------------------------------------------------|
| `changeOperator`              | `_newOperatorContract: address`                     | None                     | `external`       | Updates the operator contract address.           |
| `setMinter`                   | `_minter: address, _state: bool`                    | None                     | `external`       | Grants or revokes minter privileges.             |
| `getOwnerAmount`              | `tokenId: uint, _owner: address`                    | `uint`                   | `external`       | Retrieves the amount owned by a specific address.|
| `getTokenCnt`                 | None                                                | `uint`                   | `external`       | Returns the total number of token types.         |
| `getTokenIdByHash`            | `metadataHash: bytes32`                             | `uint`                   | `external`       | Fetches token ID associated with a metadata hash.|
| `getTokenAmount`              | `tokenId: uint`                                     | `uint`                   | `external`       | Gets the amount of a specific token type.        |
| `getTotalSupply`              | None                                                | `uint`                   | `external`       | Returns the total supply of all tokens.          |
| `uri`                         | `tokenId: uint`                                     | `string`                 | `public`         | Fetches the metadata URI for a specific token.   |
| `getManagedWallet`            | None                                                | `address`                | `external`       | Returns the address of the managed wallet.       |
| `setManagedWallet`            | `_newManagedWallet: address`                        | None                     | `external`       | Updates the managed wallet address.              |
| `setFee`                      | `_fee: uint`                                        | None                     | `external`       | Updates the transaction fee.                     |
| `getFee`                      | None                                                | `uint`                   | `external`       | Retrieves the current transaction fee.           |
| `safeBatchTransferFrom`       | `from: address`, `to: address`, `ids: uint[]`, `amounts: uint[]`, `data: bytes` | None | `public`        | Transfers tokens in batch from a single sender.  |
| `safeTransferFrom`            | `from: address`, `to: address`, `id: uint`, `amount: uint`, `data: bytes` | None | `public` | Transfers a specific token type from a sender.   |
| `getIssuer`                   | `tokenId: uint`                                     | `Issuer`                 | `external`       | Retrieves issuer details for a specific token.   |
| `mint`                        | `_uri: string`, `amount: uint`, `receiver: address`, `royalty: uint`, `accepted: bool` | `uint` | `external` | Mints a new token with specified parameters.     |
| `droplinkedSafeBatchTransferFrom` | `from: address`, `to: address[]`, `ids: uint[]`, `amounts: uint[]` | None | `external` | Transfers tokens to multiple recipients.         |

---

## 5. Requirements and Interaction Flow

1. **Deployment:**
   - Deploy the `DroplinkedToken` contract with required parameters.
2. **Role Management:**
   - Assign operator and minter roles using `changeOperator` and `setMinter`.
3. **Token Minting:**
   - Mint tokens using `mint`, specifying URI, royalty, and recipient details.
4. **Token Transfers:**
   - Use `safeTransferFrom` or `safeBatchTransferFrom` for standard transfers.
   - Use `droplinkedSafeBatchTransferFrom` for multi-recipient transfers.
5. **Fee and Wallet Management:**
   - Update the managed wallet using `setManagedWallet`.
   - Adjust transaction fees using `setFee`.

---

## 6. Additional Notes
- **Minting Control:** Restricted to addresses with minter privileges.
- **Enhanced Transfers:** Allows transferring tokens to multiple recipients in a single transaction.
- **Fee Updates:** Only the operator can update the transaction fee.

