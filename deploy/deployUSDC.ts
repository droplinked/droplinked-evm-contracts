import { ethers, upgrades } from 'hardhat';

async function main() {
	const BediToken = await ethers.getContractFactory('DroplinkedERC20Token');
	const bedi = await BediToken.deploy();
	console.log('[ ✅ ] Bedi deployed to: ', await bedi.getAddress());
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error);
		process.exit(1);
	});
