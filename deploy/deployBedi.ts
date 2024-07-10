import { ethers, upgrades } from 'hardhat';

async function main() {
    const USDCAddress = "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913";
    const BediToken = await ethers.getContractFactory('BediCoin');
    const bedi = await BediToken.deploy(BigInt(1e9)*BigInt(1e18))
    console.log('[ ✅ ] Bedi deployed to: ', await bedi.getAddress());

    // const BediPool = await ethers.getContractFactory('BediPool');
    // const bediPool = await BediPool.deploy(, USDCAddress);
    // console.log('[ ✅ ] BediPool deployed to: ', await bediPool.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })
