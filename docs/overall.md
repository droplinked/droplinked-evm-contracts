# Droplinked EVM Contracts

Droplinked contracts consist of multiple contracts that each of them has a role to play,

Here are all the contracts in droplinked ecosystem:
  
  - **DropShopDeployer** (**Deployer**):
    This contract is a factory for deploying shops and nfts, each user will deploy their own shop & nft contract through this deployer contract. More info [here](./deployer.md)
  
  - **DropShop** (**Shop**):
    This contract is the main contract that operates for each shop, it records products, holds the nfts and has the claim functionality. More info [here](./shop.md)

  - **DroplinkedPaymentProxy** (**ProxyPayer** or **Proxy**):
    This contract is the entry point for payments, It has a connection with chainlink contracts that can convert the `USD` to the `NativeCurrency` of that network, so you can have `in-contract price conversion`. It supports USD payments, custom token payments and price conversion. More info [here](./proxy.md).

You can view more info on each of the contracts by clicking on their link.

Also you can view a full documentation of how to interract with droplinked contracts [here](./interaction.md)
