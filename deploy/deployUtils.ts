import { ethers } from 'hardhat';

async function main() {
	console.log('[ 👾 ] Initializing...');
	console.log(
		`[ 👾 ] Deploying to chain: ${(await ethers.provider.getNetwork()).name}`
	);
	const TokenIdFetcher = await ethers.getContractFactory('TokenIdFetcher');
	const tokenIdFetcher = await TokenIdFetcher.deploy();
	console.log(
		'[ ✅ ] TokenIdFetcher deployed to: ',
		await tokenIdFetcher.getAddress()
	);
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
