# Droplinked Solidity Contracts

This repository contains the droplinked's smart-contracts for EVM chains that droplinked integrates with, including : Ethereum, Polygon, Base, BSC, Bitlayer, and more.

## Documentations

You can view the user documentation of the contracts, and how to use them in front/back-end over [here](./docs/overall.md)

For detailed technical documentation of the smart contract architecture and components, see [Technical Documentation](./docs/technical_documentation.md)

## Run tests

To run the tests on the contract you can run the following command in the dev branch:
`npm run test`

```txt
❯ npx hardhat test


  BulkTokenDistributor
    ERC20 Distribution
      ✔ Should distribute ERC20 tokens correctly
      ✔ Should revert with mismatched array lengths
    ERC721 Distribution
      ✔ Should distribute ERC721 tokens correctly (38ms)
    ERC1155 Distribution
      ✔ Should distribute ERC1155 tokens correctly

  Shop
    Deployment
NFT deployed to: 0x44BF2a9217A2970A1bCC7529Bf1d40828C594320
Shop deployed to: 0x6cf304A5C5Be55541C8437546649E7305bA2d598
Shop Owner: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 , owner account: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
      ✔ Should deploy shop
      ✔ Should set the right fee
    Set & Update heartbeat
      ✔ Should update the heartbeat with owner account
      ✔ should not update the heartbeat with other account
    Set & update fee
      ✔ Should update the fee to given number using owner account
      ✔ Should not update the fee to given number using other account
    Mint
      ✔ Should mint 1000 tokens via ERC1155
      ✔ Should mint the same product with the same token_id
      ✔ Should set the right product metadata
    Publish request
      ✔ Should publish a request
      ✔ Should publish publish a request with the right data
      ✔ Should not publish a request twice
    AcceptRequest
      ✔ Should accept a request
      ✔ Should not accept a request if it is not the producer
    DisapproveRequest
      ✔ Should disapprove a request
      ✔ Should not disapprove a request if it is not the producer
    NFT Claim
      ✔ Should claim an NFT (75ms)
      ✔ Should not claim an NFT twice


  22 passing (3s)
```

## Deploy

To deploy the contract to a network, follow these steps:

Add your network to the `hardhat.config.ts` file, by simply looking at the Examples that are there
Put your etherscan `api key` in the etherscan part
Run the following command to deploy:
`npm run deploy:<type> $network_name_here$`
For instance, running

`npx hardhat run deploy:deployer polygon_mumbai`
would result in something like this

```txt
[ ✅ ] Deployer deployed to: 0x34C4db97cE4cA2cce48757F85C954C5647124106 with fee: 100 and heartbeat: 120
```

There are multiple deployment scripts which you can check in the package.json file, under the `scripts` section.
