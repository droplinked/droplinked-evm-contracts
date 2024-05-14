import { ethers, upgrades } from 'hardhat';

async function main() {
    const heartBeat = 3600;
    const chainLinkAddress = "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526";
    const droplinkedWallet = "0x47a8378243f702143775a0AD75DD629935DA8AFf";
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