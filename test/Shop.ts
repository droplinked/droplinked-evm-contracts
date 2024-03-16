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
        // const Shop = await ethers.getContractFactory("Shop");
        // const shop = await Token.deploy(1e9);
        // const NFT = await ethers.getContractFactory("ExModulesNFT");
        // const nft = await NFT.deploy("Exmodule NFT", "exm");
        // const Market = await ethers.getContractFactory("ExmodulesMarketPlace");
        // const market = await Market.deploy(await token.getAddress(), 100, owner);
        // await nft.waitForDeployment();
        // await token.waitForDeployment();
        // await market.waitForDeployment();
        // token.connect(owner).setMarketPlaceContract(await market.getAddress());
        // return {token, owner, firstUser, secondUser, nft, market};
    }

    it("Should deploy shop", async function () {
        await deployContract();
    })
});