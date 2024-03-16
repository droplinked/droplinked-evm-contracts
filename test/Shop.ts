import { expect } from "chai";
import { ethers } from "hardhat";

describe("Shop", function(){
    async function deployContract() {
        const [owner,firstUser,secondUser] = await ethers.getSigners();
        const Deployer = await ethers.getContractFactory("DropShopDeployer");
        const deployer = await Deployer.deploy();
        await deployer.connect(owner).deployShop("ShopName", "Address", await owner.getAddress(), "LogoUrl", "Description");
        const shopAddress = await deployer.shopAddresses(Number(await deployer.shopCount()) - 1);
        const nftAddress = await deployer.nftContracts(Number(await deployer.shopCount()) - 1);
        console.log(shopAddress, nftAddress);
    }

    it("Should deploy shop", async function () {
        await deployContract();
    })
});