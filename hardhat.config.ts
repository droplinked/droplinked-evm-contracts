import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

import "hardhat-interface-generator";

require("dotenv").config();

const config: HardhatUserConfig = {
  networks: {
    bscTestnet:{
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: [process.env.PRIVATE_KEY as string]
    },
    polygonAmoy:{
      url: "https://rpc-amoy.polygon.technology",
      chainId: 80002,
      accounts: [process.env.PRIVATE_KEY as string]
    },
    sepolia:{
      url: "https://sepolia.infura.io/v3/",
      chainId: 11155111,
      accounts: [process.env.PRIVATE_KEY as string]
    }
  },
  solidity: {
    version: "0.8.20",
    settings: {
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  etherscan:{
    apiKey:{
      bscTestnet: (process.env.BINANCE_API_KEY) as string,
      polygonAmoy: (process.env.POLYGON_API_KEY) as string,
    },
    customChains:[
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",
          browserURL: "https://www.oklink.com/polygonAmoy"
        },
      }
    ]
  },
};

export default config;
