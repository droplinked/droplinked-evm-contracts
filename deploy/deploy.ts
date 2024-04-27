import { ethers, upgrades } from 'hardhat';

async function main() {
    const heartBeat = 3600;
    const chainLinkAddress = "0x694AA1769357215DE4FAC081bf1f309aDC325306";
    const droplinkedWallet = "0x60380cDcF09c9B6333fFC154AB7507482fAcF56a";
    const droplinkedFee = 100;
    const DropShopDeployer = await ethers.getContractFactory("DropShopDeployer");
    const deployer = await upgrades.deployProxy(DropShopDeployer, [heartBeat, droplinkedWallet, droplinkedFee], {initializer: 'initialize'});
    console.log("Deployer deployed to: ", await deployer.getAddress());
    const ProxyPayer = await ethers.getContractFactory("DroplinkedPaymentProxy");
    const proxyPayer = await upgrades.deployProxy(ProxyPayer, [heartBeat, chainLinkAddress], {initializer: 'initialize'});
    console.log("ProxyPayer deployed to: ", await proxyPayer.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })