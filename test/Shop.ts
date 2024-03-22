import { expect } from "chai";
import { ethers } from "hardhat";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { DropShopDeployer, DroplinkedToken, DropShop } from '../typechain-types';

describe("Shop", function(){
    let owner: HardhatEthersSigner;
    let firstUser: HardhatEthersSigner;
    let secondUser: HardhatEthersSigner;
    let deployer: DropShopDeployer;
    let shopAddress: string;
    let nftAddress: string;
    let nftContract: DroplinkedToken;
    let shopContract: DropShop;

    beforeEach(async function() {
        [owner,firstUser,secondUser] = await ethers.getSigners();
        const Deployer = await ethers.getContractFactory("DropShopDeployer");
        deployer = await Deployer.deploy();
        await deployer.connect(owner).deployShop("ShopName", "Address", await owner.getAddress(), "LogoUrl", "Description");
        shopAddress = await deployer.shopAddresses(Number(await deployer.shopCount()) - 1);
        nftAddress = await deployer.nftContracts(Number(await deployer.shopCount()) - 1);
        nftContract = await ethers.getContractAt("DroplinkedToken", nftAddress);
        shopContract = await ethers.getContractAt("DropShop", shopAddress);
    });

    it("Should deploy shop", async function () {
        console.log(`NFT deployed to: ${await nftContract.getAddress()}`);
        console.log(`Shop deployed to: ${await shopContract.getAddress()}`);
    })

    
});