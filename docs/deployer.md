# Detailed Documentation for DropShopDeployer

## Purpose

The DropShopDeployer contract is designed to manage the deployment and configuration of NFT drop shops and their associated contracts. It also maintains operational configurations like fees and heartbeat intervals.

## Key Components

## Libraries and Interfaces

### Libraries Imported:
- Initializable (for upgradeable contracts).
- OwnableUpgradeable (for access control).

### Custom Interfaces and Contracts:
  [IDIP1](./IDIP1.md), [DropERC1155](./DropERC1155.md), [IDropShop](./IDropShop.md) (specific to the platform).

### Events
1. ShopDeployed:
    - Triggered after deploying a new shop and associated NFT contract.
    - Parameters:
      address shop: Address of the deployed shop.
      address nftContract: Address of the associated NFT contract.

2. DroplinkedFeeUpdated:

    - Emitted upon updating the Droplinked fee.
    - Parameters:
        uint256 newFee: The new fee amount.

3. HeartBeatUpdated:

    - Emitted upon updating the heartbeat interval.
    - Parameters:
        uint256 newHeartBeat: The new interval value.

## State Variables

### Data Storage:

``` solidity
IDropShop[] public shopAddresses; // List of deployed shops.
address[] public nftContracts; // List of NFT contracts.
mapping(address => address[]) public shopOwners; // Owner-to-shops mapping.
mapping(address => address[]) public nftOwners; // Owner-to-NFTs mapping.
```

### Configuration Variables:

```solidity
uint256 public droplinkedFee; // Fee percentage for Droplinked services.
uint256 public heartBeat; // Heartbeat interval.
address public droplinkedWallet; // Wallet to receive fees.
uint256 public shopCount; // Total deployed shops.
```

## Functions

1. **Initialization**

  - Function: initialize(uint256 _heartBeat, address _droplinkedWallet, uint256 _droplinkedFee)
  - Purpose: Initializes the contract and its state variables.
  - Parameters:
    - _heartBeat: Initial heartbeat interval.
    - _droplinkedWallet: Address for receiving fees.
    - _droplinkedFee: Initial fee value.
    - Access: Can only be called once (via initializer).

2. **Fee and Heartbeat Management**
  - Function: setDroplinkedFee(uint256 newFee)
    - Purpose: Updates the fee.
    - Emits: DroplinkedFeeUpdated(newFee).
    - Restricted to owner.
  - Function: setHeartBeat(uint256 newHeartBeat)
    - Updates the heartbeat interval.
    - Emits HeartBeatUpdated(newHeartBeat).
    - Restricted to owner.

3. **Shop Deployment**
  - Function: deployShop(bytes memory bytecode, bytes32 salt)
    - Purpose: Deploys a new shop and associated NFT contract using CREATE2.
    - Process:
      - Deploys the shop contract.
      - Ensures the contract deployment was successful.
      - Associates the shop with the caller's address in shopOwners.
      - Records the shop in shopAddresses and associated NFT contract in nftContracts.
      - Increments shopCount.
      - Emits ShopDeployed(shop, nftContract).
    - Parameters:
      - bytecode: Contract bytecode for the shop.
      - salt: Unique salt for deterministic deployment.
    - Returns:
      - address shop: Address of the deployed shop.
      - address nftContract: Address of the associated NFT contract.

## Contract Workflow

### 1. Initialization:

The contract is initialized with initialize.
Sets heartbeat, wallet, and fee configurations.

### 2. Deploying a Shop:

Users can deploy a shop by calling deployShop, providing bytecode and a salt.
Tracks deployment with shopAddresses and shopOwners.
### 3. Updating Configurations:

The owner can modify fees and heartbeat values using setDroplinkedFee and setHeartBeat.

### 4. Emitted Events:

- Successful deployments emit ShopDeployed.
- Configuration updates emit their respective events.

## Security Considerations

- Ownership: Restricted to the contract owner for sensitive actions like updating fees or heartbeats.
- Deployment Safety: Uses CREATE2 for deterministic deployment but ensures contract code size post-deployment.
- Initialization Protection: Prevents re-initialization using initializer.

