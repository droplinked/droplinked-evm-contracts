import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@openzeppelin/hardhat-upgrades';

import 'hardhat-interface-generator';

require('dotenv').config();

const INFURA_API_KEY = process.env.INFURA_API_KEY;

const config: HardhatUserConfig = {
	networks: {
		ethereumMainnet: {
			url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
			chainId: 1,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		skale: {
			url: 'https://mainnet.skalenodes.com/v1/honorable-steel-rasalhague',
			chainId: 1564830818,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		skaleCalypso: {
			url: 'https://testnet.skalenodes.com/v1/giant-half-dual-testnet',
			chainId: 974399131,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		bscTestnet: {
			url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
			chainId: 97,
			gasPrice: 20000000000,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		bsc: {
			url: 'https://bsc-dataseed.binance.org/',
			chainId: 56,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		polygonAmoy: {
			url: 'https://rpc-amoy.polygon.technology',
			chainId: 80002,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		polygon: {
			url: 'https://polygon-rpc.com/',
			chainId: 137,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		linea: {
			url: 'https://1rpc.io/linea',
			chainId: 59144,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		base: {
			url: 'https://mainnet.base.org/',
			chainId: 8453,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		baseSepolia: {
			url: 'https://sepolia.base.org/',
			chainId: 84532,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		sepolia: {
			url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
			chainId: 11155111,
			accounts: [process.env.PRIVATE_KEY as string],
		},
		redbellyTestNet: {
			url: 'https://governors.testnet.redbelly.network',
			chainId: 153,
			accounts: [process.env.PRIVATE_KEY_RDBLY as string],
		},
		redbelly: {
			url: 'https://governors.mainnet.redbelly.network',
			accounts: [process.env.PRIVATE_KEY as string],
		},
		bitlayerTestnet: {
			url: 'https://testnet-rpc.bitlayer.org',
			accounts: [process.env.PRIVATE_KEY as string],
		},
		bitlayer: {
			url: 'https://rpc.bitlayer.org',
			accounts: [process.env.PRIVATE_KEY as string],
		},
	},
	solidity: {
		version: '0.8.20',
		settings: {
			viaIR: true,
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	etherscan: {
		apiKey: {
			redbelly: 'redbelly',
			bscTestnet: process.env.BINANCE_API_KEY as string,
			bsc: process.env.BINANCE_API_KEY as string,
			polygonAmoy: process.env.POLYGON_API_KEY as string,
			polygon: process.env.POLYGON_API_KEY as string,
			base: process.env.BASE_API_KEY as string,
			linea: process.env.LINEA_API_KEY as string,
			ethereumMainnet: process.env.ETH_API_KEY as string,
			sepolia: process.env.ETH_API_KEY as string,
			baseSepolia: process.env.BASE_API_KEY as string,
			RedbellyTestNet: '1234',
			bitlayerTestnet: '1234',
			bitlayer: '1234',
		},
		customChains: [
			{
				network: 'polygonAmoy',
				chainId: 80002,
				urls: {
					apiURL: 'https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy',
					browserURL: 'https://www.oklink.com/polygonAmoy',
				},
			},
			{
				network: 'linea',
				chainId: 59144,
				urls: {
					apiURL: 'https://api.lineascan.build/api',
					browserURL: 'https://goerli.lineascan.build/',
				},
			},
			{
				network: 'RedbellyTestNet',
				chainId: 153,
				urls: {
					apiURL: 'https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy',
					browserURL: 'https://explorer.testnet.redbelly.network',
				},
			},
			{
				network: 'redbelly',
				chainId: 151,
				urls: {
					apiURL: 'https://api.routescan.io/v2/network/mainnet/evm/151/etherscan',
					browserURL: 'https://redbelly.routescan.io',
				},
			},
			{
				network: 'bitlayerTestnet',
				chainId: 200810,
				urls: {
					apiURL: 'https://api-testnet.btrscan.com/scan/api',
					browserURL: 'https://testnet.btrscan.com/',
				},
			},
			{
				network: 'bitlayer',
				chainId: 200901,
				urls: {
					apiURL: 'https://api.btrscan.com/scan/api',
					browserURL: 'https://www.btrscan.com/',
				},
			},
		],
	},
};

export default config;
