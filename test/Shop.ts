import { expect } from 'chai';
import { ethers, upgrades } from 'hardhat';
import { HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import {
	DropShopDeployer,
	DroplinkedToken,
	DropShop,
	DroplinkedPaymentProxy,
} from '../typechain-types';
import { ProductStructOutput } from '../typechain-types/contracts/interfaces/IDIP1';
import dotenv from 'dotenv';
import { bytecode } from '../artifacts/contracts/base/Shop.sol/DropShop.json';
dotenv.config();

enum ProductType {
	DIGITAL,
	POD,
	PHYSICAL,
}

enum NFTType {
	ERC1155,
	ERC721,
}

async function getProductId(nftAddress: string, tokenId: number) {
	const hash = ethers.keccak256(
		ethers.AbiCoder.defaultAbiCoder().encode(
			['address', 'uint256'],
			[nftAddress, tokenId]
		)
	);
	const hashAsUint256 = ethers.toBigInt(hash);
	return hashAsUint256.toString();
}

describe('Shop', function () {
	let owner: HardhatEthersSigner;
	let firstUser: HardhatEthersSigner;
	let secondUser: HardhatEthersSigner;
	let thirdUser: HardhatEthersSigner;
	let fourthUser: HardhatEthersSigner;
	let deployer: DropShopDeployer;
	let shopAddress: string;
	let nftAddress: string;
	let nftContract: DroplinkedToken;
	let shopContract: DropShop;
	let paymentProxy: DroplinkedPaymentProxy;

	beforeEach(async function () {
		[owner, firstUser, secondUser, thirdUser, fourthUser] =
			await ethers.getSigners();
		const ChainLink = await ethers.getContractFactory('chainLink');
		const chainlink = await ChainLink.deploy();
		const Deployer = await ethers.getContractFactory('DropShopDeployer');
		deployer = (await upgrades.deployProxy(
			Deployer,
			[120, secondUser.address, 100],
			{ initializer: 'initialize' }
		)) as any;
		const PaymentProxy = await ethers.getContractFactory(
			'DroplinkedPaymentProxy'
		);
		paymentProxy = (await PaymentProxy.deploy(
			120,
			await chainlink.getAddress()
		)) as any;
		// address usdcTokenAddress, address routerAddress, address nativeTokenWrapper
		const constructorArgs = [
			'ShopName',
			'Los Angeles',
			owner.address,
			'https://127.0.0.1/lol.png',
			'Desc',
			await deployer.getAddress(),
		];
		const bytecodeWithArgs = ethers.AbiCoder.defaultAbiCoder().encode(
			['string', 'string', 'address', 'string', 'string', 'address'],
			constructorArgs
		);
		await deployer
			.connect(owner)
			.deployShop(
				bytecode + bytecodeWithArgs.split('0x')[1],
				'0x0000000000000000000000000000000000000000000000000000000000000001'
			);
		shopAddress = await deployer.shopAddresses(
			Number(await deployer.shopCount()) - 1
		);
		nftAddress = await deployer.nftContracts(
			Number(await deployer.shopCount()) - 1
		);
		nftContract = await ethers.getContractAt('DroplinkedToken', nftAddress);
		shopContract = await ethers.getContractAt('DropShop', shopAddress);
	});

	describe('Deployment', function () {
		it('Should deploy shop', async function () {
			console.log(`NFT deployed to: ${await nftContract.getAddress()}`);
			console.log(
				`Shop deployed to: ${await shopContract.getAddress()}`
			);
			console.log(
				`Shop Owner: ${await shopContract.owner()} , owner account: ${await owner.getAddress()}`
			);
		});

		it('Should set the right fee', async function () {
			expect(await deployer.droplinkedFee()).to.equal(100);
		});
	});

	describe('Set & Update heartbeat', function () {
		it('Should update the heartbeat with owner account', async function () {
			await deployer.connect(owner).setHeartBeat(4000);
			expect(await deployer.getHeartBeat()).to.equal(4000);
		});
		it('should not update the heartbeat with other account', async function () {
			await expect(
				deployer.connect(firstUser).setHeartBeat(4000)
			).to.be.revertedWithCustomError(
				deployer,
				'OwnableUnauthorizedAccount'
			);
		});
	});

	describe('Set & update fee', function () {
		it('Should update the fee to given number using owner account', async function () {
			await deployer.connect(owner).setDroplinkedFee(200);
			expect(await deployer.getDroplinkedFee()).to.equal(200);
		});
		it('Should not update the fee to given number using other account', async function () {
			await expect(
				deployer.connect(firstUser).setDroplinkedFee(200)
			).to.be.revertedWithCustomError(
				deployer,
				'OwnableUnauthorizedAccount'
			);
		});
	});

	describe('Mint', function () {
		it('Should mint 1000 tokens via ERC1155', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			expect(
				await nftContract.balanceOf(
					await shopContract.getAddress(),
					1
				)
			).to.equal(1000);
		});

		it('Should mint the same product with the same token_id', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			expect(
				await nftContract.balanceOf(
					await shopContract.getAddress(),
					1
				)
			).to.equal(2000);
			let result: ProductStructOutput;

			result = await shopContract.getProduct(
				await getProductId(nftAddress, 1)
			);
			expect(result.tokenId).to.equal(1);
			expect(result.nftType).to.equal(NFTType.ERC1155);
		});

		it('Should set the right product metadata', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			expect(
				await nftContract.balanceOf(
					await shopContract.getAddress(),
					1
				)
			).to.equal(1000);
			let result: ProductStructOutput;
			result = await shopContract.getProduct(
				await getProductId(nftAddress, 1)
			);
			const tokenURI = await nftContract.uris(1);
			expect(tokenURI).to.equal('ipfs.io/ipfs/randomhash');
		});
	});

	describe('Publish request', function () {
		it('Should publish a request', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			const affiliateReq = await shopContract.affiliateRequests(0);
			expect(affiliateReq.isConfirmed).to.equal(false);
			expect(affiliateReq.publisher).to.equal(firstUser.address);
			expect(affiliateReq.productId).to.equal(
				await getProductId(nftAddress, 1)
			);
		});

		it('Should publish publish a request with the right data', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			const affiliateReq = await shopContract.affiliateRequests(0);
			expect(affiliateReq.isConfirmed).to.equal(false);
			expect(affiliateReq.publisher).to.equal(firstUser.address);
			expect(affiliateReq.productId).to.equal(
				await getProductId(nftAddress, 1)
			);
		});

		it('Should not publish a request twice', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			await expect(
				shopContract
					.connect(firstUser)
					.requestAffiliate(
						await getProductId(nftAddress, 1)
					)
			).to.be.revertedWithCustomError(shopContract, 'AlreadyRequested');
		});
	});

	describe('AcceptRequest', function () {
		it('Should accept a request', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			await shopContract.connect(owner).approveRequest(0);
			const affiliateReq = await shopContract.affiliateRequests(0);
			expect(affiliateReq.isConfirmed).to.equal(true);
		});
		it('Should not accept a request if it is not the producer', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			await expect(
				shopContract.connect(secondUser).approveRequest(0)
			).to.be.revertedWithCustomError(
				shopContract,
				'OwnableUnauthorizedAccount'
			);
		});
	});

	describe('DisapproveRequest', function () {
		it('Should disapprove a request', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			await shopContract.connect(owner).approveRequest(0);
			await shopContract.connect(owner).disapproveRequest(0);
			const affiliateReq = await shopContract.affiliateRequests(0);
			expect(affiliateReq.isConfirmed).to.equal(false);
		});

		it('Should not disapprove a request if it is not the producer', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			await shopContract
				.connect(firstUser)
				.requestAffiliate(await getProductId(nftAddress, 1));
			await shopContract.connect(owner).approveRequest(0);
			await expect(
				shopContract.connect(secondUser).disapproveRequest(0)
			).to.be.revertedWithCustomError(
				shopContract,
				'OwnableUnauthorizedAccount'
			);
		});
	});

	describe('NFT Claim', function () {
		it('Should claim an NFT', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			const manager = '0x666837f8fF5fa9106304f9F94a95dF56777599A1';
			await shopContract.setManager(manager);
			const ownerPrivateKey =
				'bef64391626b764c6b0709f0835ec586756a465cec26e6e96f89bfe1e57f0260';
			const wallet = new ethers.Wallet(ownerPrivateKey);
			const nullifier = ethers.keccak256(
				Buffer.from(
					Date.now().toString() +
						`droplinked_sign_2_${await getProductId(
							nftAddress,
							1
						)}`
				)
			);
			const data = [
				{
					amount: 2,
					productId: await getProductId(nftAddress, 1),
					nullifier,
				},
			];
			const types = [
				'tuple(tuple(uint256 amount, uint256 productId, uint256 nullifier)[] cart, address shop)',
			];
			const values = [{ cart: data, shop: shopAddress }];
			const abiCoder = ethers.AbiCoder.defaultAbiCoder();
			const encodedData = abiCoder.encode(types, values);
			const messageHash = ethers.keccak256(encodedData);
			const messageBytes = ethers.getBytes(messageHash);
			const signature = await wallet.signMessage(messageBytes);
			await shopContract.claimPurchase(manager, signature, {
				cart: [
					{
						amount: 2,
						productId: await getProductId(
							nftAddress,
							1
						),
						nullifier,
					},
				],
				shop: shopAddress,
			});
		});
		it('Should not claim an NFT twice', async function () {
			await shopContract.connect(owner).mintAndRegister({
				accepted: true,
				affiliatePercentage: 100,
				amount: 1000,
				nftAddress: await nftContract.getAddress(),
				nftType: NFTType.ERC1155,
				productType: ProductType.DIGITAL,
				royalty: 1200,
				uri: 'ipfs.io/ipfs/randomhash',
			});
			const manager = '0x666837f8fF5fa9106304f9F94a95dF56777599A1';
			await shopContract.setManager(manager);
			const ownerPrivateKey =
				'bef64391626b764c6b0709f0835ec586756a465cec26e6e96f89bfe1e57f0260';
			const wallet = new ethers.Wallet(ownerPrivateKey);
			const nullifier = ethers.keccak256(
				Buffer.from(
					Date.now().toString() +
						`droplinked_sign_2_${await getProductId(
							nftAddress,
							1
						)}`
				)
			);
			const data = [
				{
					amount: 2,
					productId: await getProductId(nftAddress, 1),
					nullifier,
				},
			];
			const types = [
				'tuple(tuple(uint256 amount, uint256 productId, uint256 nullifier)[] cart, address shop)',
			];
			const values = [{ cart: data, shop: shopAddress }];
			const abiCoder = ethers.AbiCoder.defaultAbiCoder();
			const encodedData = abiCoder.encode(types, values);
			const messageHash = ethers.keccak256(encodedData);
			const messageBytes = ethers.getBytes(messageHash);
			const signature = await wallet.signMessage(messageBytes);
			await shopContract.claimPurchase(manager, signature, {
				cart: [
					{
						amount: 2,
						productId: await getProductId(
							nftAddress,
							1
						),
						nullifier: nullifier,
					},
				],
				shop: shopAddress,
			});
			await expect(
				shopContract.claimPurchase(manager, signature, {
					cart: [
						{
							amount: 2,
							productId: await getProductId(
								nftAddress,
								1
							),
							nullifier: nullifier,
						},
					],
					shop: shopAddress,
				})
			).to.be.revertedWithCustomError(shopContract, 'AlreadyClaimed');
		});
	});
});
