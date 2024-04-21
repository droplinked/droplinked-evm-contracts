import { expect } from "chai";
import { ethers } from "hardhat";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { DropShopDeployer, DroplinkedToken, DropShop } from '../typechain-types';
import { ProductStructOutput } from "../typechain-types/contracts/interfaces/IDIP1";

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

async function getProductId(nftAddress: string, tokenId: number) {
    // Encode the parameters and calculate the keccak256 hash
    const hash = ethers.keccak256(
        ethers.AbiCoder.defaultAbiCoder().encode(
            ["address", "uint256"],
            [nftAddress, tokenId])
    );
    const hashAsUint256 = ethers.toBigInt(hash);
    // console.log("Hash as BigNumber:", hashAsUint256.toString());
    return hashAsUint256.toString();
}


describe("Shop", function () {
    let owner: HardhatEthersSigner;
    let firstUser: HardhatEthersSigner;
    let secondUser: HardhatEthersSigner;
    let deployer: DropShopDeployer;
    let shopAddress: string;
    let nftAddress: string;
    let nftContract: DroplinkedToken;
    let shopContract: DropShop;

    beforeEach(async function () {
        [owner, firstUser, secondUser] = await ethers.getSigners();
        const Deployer = await ethers.getContractFactory("DropShopDeployer");
        deployer = await Deployer.deploy(120);
        await deployer.connect(owner).deployShop("ShopName", "Address", "LogoUrl", "Description");
        shopAddress = await deployer.shopAddresses(Number(await deployer.shopCount()) - 1);
        nftAddress = await deployer.nftContracts(Number(await deployer.shopCount()) - 1);
        nftContract = await ethers.getContractAt("DroplinkedToken", nftAddress);
        shopContract = await ethers.getContractAt("DropShop", shopAddress);
    });

    describe("Deployment", function () {
        it("Should deploy shop", async function () {
            console.log(`NFT deployed to: ${await nftContract.getAddress()}`);
            console.log(`Shop deployed to: ${await shopContract.getAddress()}`);
            console.log(`Shop Owner: ${await shopContract.owner()} , owner account: ${await owner.getAddress()}`);
        });

        it("Should set the right fee", async function () {
            expect(await deployer.droplinkedFee()).to.equal(100);
        });
    })


    describe("Set & Update heartbeat", function () {
        it("Should update the heartbeat with owner account", async function () {
            await deployer.connect(owner).setHeartBeat(4000);
            expect(await deployer.getHeartBeat()).to.equal(4000);
        });
        it("should not update the heartbeat with other account", async function () {
            await expect(deployer.connect(firstUser).setHeartBeat(4000)).to.be.revertedWithCustomError(deployer, "OwnableUnauthorizedAccount");
        });
    });

    describe("Set & update fee", function () {
        it("Should update the fee to given number using owner account", async function () {
            await deployer.connect(owner).setDroplinkedFee(200);
            expect(await deployer.getDroplinkedFee()).to.equal(200);
        });
        it("Should not update the fee to given number using other account", async function () {
            await expect(deployer.connect(firstUser).setDroplinkedFee(200)).to.be.revertedWithCustomError(deployer, "OwnableUnauthorizedAccount");
        });
    });

    describe("Mint", function () {
        it("Should mint 5000 tokens via ERC1155", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            expect(await nftContract.balanceOf(await shopContract.getAddress(), 1)).to.equal(1000);
        });

        it("Should mint the same product with the same token_id", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            expect(await nftContract.balanceOf(await shopContract.getAddress(), 1)).to.equal(2000);
            let result: ProductStructOutput;

            result = await shopContract.getProduct(await getProductId(nftAddress, 1));
            expect(result.tokenId).to.equal(1);
            expect(result.nftType).to.equal(NFTType.ERC1155);
            expect(result.paymentInfo.paymentType).to.equal(PaymentMethodType.NATIVE_TOKEN);
        });

        it("Should set the right product metadata", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            expect(await nftContract.balanceOf(await shopContract.getAddress(), 1)).to.equal(1000);
            let result: ProductStructOutput;
            result = await shopContract.getProduct(await getProductId(nftAddress, 1));
            const tokenURI = await nftContract.uris(1);
            expect(tokenURI).to.equal("ipfs.io/ipfs/randomhash");
        });

        it("should set the right beneficiaries when minting", async function () {
            const beneficaries: Beneficiary[] = [
                {
                    isPercentage: true,
                    value: 1200,
                    wallet: owner.address
                }
            ];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            expect(await nftContract.balanceOf(await shopContract.getAddress(), 1)).to.equal(1000);
            const beneficiaryId = (await shopContract.getProduct(await getProductId(nftAddress, 1))).paymentInfo.beneficiaries[0];
            const beneficiary = await shopContract.getBeneficiary(beneficiaryId);
            expect(beneficiary.isPercentage).to.equal(true);
            expect(beneficiary.wallet).to.equal(owner.address);
            expect(beneficiary.value).to.equal(1200);
        });
    });

    describe("Publish request", function () {
        it("Should publish a request", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            const affiliateReq = await shopContract.affiliateRequests(0);
            expect(affiliateReq.isConfirmed).to.equal(false);
            expect(affiliateReq.publisher).to.equal(firstUser.address);
            expect(affiliateReq.productId).to.equal(await getProductId(nftAddress, 1));
        });

        it("Should publish publish a request with the right data", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            const affiliateReq = await shopContract.affiliateRequests(0);
            expect(affiliateReq.isConfirmed).to.equal(false);
            expect(affiliateReq.publisher).to.equal(firstUser.address);
            expect(affiliateReq.productId).to.equal(await getProductId(nftAddress, 1));
        });

        it("Should not publish a request twice", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            await expect(shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1))).to.be.revertedWithCustomError(shopContract, "AlreadyRequested");
        });
    });

    describe("AcceptRequest", function () {
        it("Should accept a request", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            await shopContract.connect(owner).approveRequest(0);
            const affiliateReq = await shopContract.affiliateRequests(0);
            expect(affiliateReq.isConfirmed).to.equal(true);
        });
        it("Should not accept a request if it is not the producer", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            await expect(shopContract.connect(secondUser).approveRequest(0)).to.be.revertedWithCustomError(shopContract, "OwnableUnauthorizedAccount");
        });
    });

    describe("DisapproveRequest", function () {
        it("Should disapprove a request", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            await shopContract.connect(owner).approveRequest(0);
            await shopContract.connect(owner).disapproveRequest(0);
            const affiliateReq = await shopContract.affiliateRequests(0);
            expect(affiliateReq.isConfirmed).to.equal(false);
        });

        it("Should not disapprove a request if it is not the producer", async function () {
            const beneficaries: Beneficiary[] = [];
            await shopContract.connect(owner).mintAndRegister(
                await nftContract.getAddress(),
                "ipfs.io/ipfs/randomhash",
                1000,
                true,
                100,
                2300,
                "0x0000000000000000000000000000000000000000",
                100,
                NFTType.ERC1155,
                ProductType.DIGITAL,
                PaymentMethodType.NATIVE_TOKEN,
                beneficaries
            );
            await shopContract.connect(firstUser).requestAffiliate(await getProductId(nftAddress, 1));
            await shopContract.connect(owner).approveRequest(0);
            await expect(shopContract.connect(secondUser).disapproveRequest(0)).to.be.revertedWithCustomError(shopContract, "OwnableUnauthorizedAccount");
        });
    });
});