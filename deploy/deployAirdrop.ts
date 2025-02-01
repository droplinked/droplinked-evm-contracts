import { ethers } from 'hardhat';

async function main() {
	console.log('[ 👾 ] Initializing...');
	console.log(
		`[ 👾 ] Deploying to chain: ${(await ethers.provider.getNetwork()).name}`
	);
	const ProxyPayer = await ethers.getContractFactory('BulkTokenDistributor');
	const proxyPayer = await ProxyPayer.deploy();
	console.log(
		'[ ✅ ] AirdropContract deployed to: ',
		await proxyPayer.getAddress()
	);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
