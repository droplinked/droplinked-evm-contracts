import { ethers } from 'hardhat';

async function main() {
	const USDCToken = await ethers.getContractFactory('DroplinkedERC20Token');
	const usdc = await USDCToken.deploy();
	console.log('[ ✅ ] USDC deployed to: ', await usdc.getAddress());
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
