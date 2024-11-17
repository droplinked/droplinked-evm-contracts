# Droplinked Solidity Contracts

This repository contains the droplinked's smart-contract source code for EVM chains that droplinked integrates with, including : Polygon, Binance, Hedera and Ripple sidechain

## Documentations

You can view the documentations of the contracts, and how to use them in front/back-end over [here](./docs/overall.md)

## Run tests

To run the tests on the contract you can run the following command in the dev branch:
`npm run test`

```
  Shop
    Deployment
NFT deployed to: 0x5392A33F7F677f59e833FEBF4016cDDD88fF9E67
Shop deployed to: 0x17548A4ecf246B41889e49b1c5E80909116D62A5
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
      ✔ Should mint the same product with the same token_id (42ms)
      ✔ Should set the right product metadata
    Publish request
      ✔ Should publish a request
      ✔ Should publish publish a request with the right data
      ✔ Should not publish a request twice
    Publish request
      ✔ Should publish a request
      ✔ Should publish publish a request with the right data
    Publish request
      ✔ Should publish a request
    Publish request
      ✔ Should publish a request
      ✔ Should publish publish a request with the right data
    Publish request
      ✔ Should publish a request
    Publish request
    Publish request
    Publish request
    Publish request
    Publish request
      ✔ Should publish a request
    Publish request
      ✔ Should publish a request
      ✔ Should publish publish a request with the right data
      ✔ Should publish publish a request with the right data
      ✔ Should not publish a request twice
    AcceptRequest
      ✔ Should accept a request
      ✔ Should not accept a request if it is not the producer
    DisapproveRequest
      ✔ Should disapprove a request
      ✔ Should not disapprove a request if it is not the producer
    NFT Claim
      ✔ Should claim an NFT (119ms)
      ✔ Should not claim an NFT twice (48ms)


  18 passing (3s)
```

## Deploy

To deploy the contract to a network, follow these steps:

Add your network to the `hardhat.config.ts` file, by simply looking at the exapmles that are there
Put your etherscan `api key` in the etherscan part
Run the following command to deploy :
`npx hardhat run scripts/deploy.ts --network $network_name_here$`
For instance, running

npx hardhat run scripts/deploy.ts --network polygon_mumbai
would result in something like this

[ ✅ ] Deployer deployed to: 0x34C4db97cE4cA2cce48757F85C954C5647124106 with fee: 100 and heartbeat: 120

[ ✅ ] PaymentProxy deployed to: 0x34C4db97cE4cA2cce48757F85C954C5647124106
