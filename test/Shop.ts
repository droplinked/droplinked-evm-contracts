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
        deployer = await Deployer.deploy(120);
        await deployer.connect(owner).deployShop("ShopName", "Address", "LogoUrl", "Description");
        shopAddress = await deployer.shopAddresses(Number(await deployer.shopCount()) - 1);
        nftAddress = await deployer.nftContracts(Number(await deployer.shopCount()) - 1);
        nftContract = await ethers.getContractAt("DroplinkedToken", nftAddress);
        shopContract = await ethers.getContractAt("DropShop", shopAddress);
    });

    describe("Deployment", function(){
        it("Should deploy shop", async function () {
            console.log(`NFT deployed to: ${await nftContract.getAddress()}`);
            console.log(`Shop deployed to: ${await shopContract.getAddress()}`);
            console.log(`Shop Owner: ${await shopContract.owner()} , owner account: ${await owner.getAddress()}`);
        });
        
        it("Should set the right fee", async function() {
            expect(await deployer.droplinkedFee()).to.equal(100);
        });
    })
    

    describe("Set & Update heartbeat", function(){
        it("Should update the heartbeat with owner account", async function(){
            await deployer.connect(owner).setHeartBeat(4000);
            expect(await deployer.getHeartBeat()).to.equal(4000);
        });
        it("should not update the heartbeat with other account", async function(){
            await expect(deployer.connect(firstUser).setHeartBeat(4000)).to.be.revertedWithCustomError(deployer, "OwnableUnauthorizedAccount");
        });
    });

    describe("Set & update fee", function(){
        it("Should update the fee to given number using owner account", async function(){
            await deployer.connect(owner).setDroplinkedFee(200);
            expect(await deployer.getDroplinkedFee()).to.equal(200);
        });
        it("Should not update the fee to given number using other account", async function(){
            await expect(deployer.connect(firstUser).setDroplinkedFee(200)).to.be.revertedWithCustomError(deployer, "OwnableUnauthorizedAccount");
        });
    });

    describe("Mint", function(){
        it("Should mint 5000 tokens", async function(){
            enum ProductType {
                DIGITAL,
                POD,
                PHYSICAL
            };
            enum PaymentMethodType {
                NATIVE_TOKEN,
                USD,
                TOKEN
            };
            type Beneficiary = {
                isPercentage: boolean,
                value: number,
                wallet: string
            };
            enum NFTType {
                ERC1155,
                ERC721
            };
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                NFTType.ERC1155,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
        });
    });
});