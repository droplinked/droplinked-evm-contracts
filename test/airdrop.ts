import { expect } from 'chai';
import { ethers } from 'hardhat';
import { BulkTokenDistributor, ERC1155Mock } from '../typechain-types';
import { AddressLike } from 'ethers';

describe('BulkTokenDistributor', function () {
	let distributor: BulkTokenDistributor;
	let erc1155: ERC1155Mock;
	let owner: any, addr1: any, addr2: any, addr3: any;

	before(async function () {
		[owner, addr1, addr2, addr3] = await ethers.getSigners();

		const Distributor = await ethers.getContractFactory('BulkTokenDistributor');
		distributor = await Distributor.deploy();

		// Deploy test tokens
		const ERC20Mock = await ethers.getContractFactory('ERC20Mock');
		this.erc20 = await ERC20Mock.deploy('TestToken', 'TT', await owner.getAddress(), 1000000);

		const ERC721Mock = await ethers.getContractFactory('ERC721Mock');
		this.erc721 = await ERC721Mock.deploy('TestNFT', 'TNFT');

		const ERC1155MockContract = await ethers.getContractFactory('ERC1155Mock');
		this.erc1155 = await ERC1155MockContract.deploy();
	});

	describe('ERC20 Distribution', function () {
		it('Should distribute ERC20 tokens correctly', async function () {
			const recipients = [
				await addr1.getAddress(),
				await addr2.getAddress(),
				await addr3.getAddress(),
			];
			const amounts = [100, 200, 300];
			const total = amounts.reduce((a, b) => a + b, 0);

			// Approve distributor
			await this.erc20.approve(await distributor.getAddress(), total);

			// Distribute tokens
			await distributor.distributeERC20(
				await this.erc20.getAddress(),
				recipients,
				amounts,
				'memo'
			);

			// Check balances
			expect(await this.erc20.balanceOf(await addr1.getAddress())).to.equal(100);
			expect(await this.erc20.balanceOf(await addr2.getAddress())).to.equal(200);
			expect(await this.erc20.balanceOf(await addr3.getAddress())).to.equal(300);
		});

		it('Should revert with mismatched array lengths', async function () {
			await expect(
				distributor.distributeERC20(
					await this.erc20.getAddress(),
					[await addr1.getAddress()],
					[100, 200],
					'memo'
				)
			).to.be.revertedWithCustomError(distributor, 'ArrayLengthMismatch');
		});
	});

	describe('ERC721 Distribution', function () {
		it('Should distribute ERC721 tokens correctly', async function () {
			const recipients = [
				await addr1.getAddress(),
				await addr2.getAddress(),
				await addr3.getAddress(),
			];
			const tokenIds = [1, 2, 3];

			// Mint tokens to owner
			for (const id of tokenIds) {
				await this.erc721.mint(await owner.getAddress(), id);
				await this.erc721.approve(await distributor.getAddress(), id);
			}

			// Distribute tokens
			await distributor.distributeERC721(
				await this.erc721.getAddress(),
				recipients,
				tokenIds,
				'memo'
			);

			// Check ownership
			expect(await this.erc721.ownerOf(1)).to.equal(await addr1.getAddress());
			expect(await this.erc721.ownerOf(2)).to.equal(await addr2.getAddress());
			expect(await this.erc721.ownerOf(3)).to.equal(await addr3.getAddress());
		});
	});

	describe('ERC1155 Distribution', function () {
		it('Should distribute ERC1155 tokens correctly', async function () {
			const recipients = [
				await addr1.getAddress(),
				await addr2.getAddress(),
				await addr3.getAddress(),
			];
			const tokenId = 1;
			const amountPerRecipient = 10;
			const total = recipients.length * amountPerRecipient;

			// Mint tokens to owner
			await this.erc1155.mint(await owner.getAddress(), tokenId, total, '0x');

			// Approve distributor
			await this.erc1155.setApprovalForAll(await distributor.getAddress(), true);

			// Distribute tokens
			await distributor.distributeERC1155(
				(await this.erc1155.getAddress()) as string,
				tokenId,
				recipients as AddressLike[],
				[amountPerRecipient, amountPerRecipient, amountPerRecipient],
				'memo'
			);

			// Check balances
			for (const recipient of recipients) {
				expect(await this.erc1155.balanceOf(recipient, tokenId)).to.equal(10);
			}
			expect(await this.erc1155.balanceOf(await owner.getAddress(), tokenId)).to.equal(0);
		});
	});
});
