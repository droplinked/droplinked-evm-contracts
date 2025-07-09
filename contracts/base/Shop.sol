// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDIP1, ShopInfo, Product, AffiliateRequest, NFTType, ProductType, Issuer, RecordData} from "../interfaces/IDIP1.sol";
import {SignatureVerifier} from "./SignatureVerifier.sol";
import {PurchasedItem, PurchaseSignature} from "../structs/Structs.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface DroplinkedToken1155 {
    function mint(
        string calldata _uri,
        uint256 amount,
        address receiver,
        uint256 royalty,
        bool accepted
    ) external returns (uint256);
    function issuers(uint256 tokenId) external view returns (Issuer memory);
}

contract DropShop is
    IDIP1,
    Ownable,
    IERC721Receiver,
    IERC1155Receiver,
    SignatureVerifier,
    ReentrancyGuard
{
    bool private receivedProduct;
    ShopInfo public shopInfo;
    mapping(uint256 productId => Product product) public products;
    mapping(uint256 productId => mapping(address requester => bool))
        public isRequestSubmited;
    mapping(uint256 requestId => AffiliateRequest affiliateRequest)
        public affiliateRequests;

    mapping(address => bool) public managers;
    mapping(uint256 => bool) public nullifiers;
    address private constant DROPLINKED_MANAGER_WALLET =
        0x2F86E1B1A69D259b9609b40E3cbEBEa29946f979;

    uint256 public productCount;
    uint256 public affiliateRequestCount;

    modifier notRequested(uint256 productId, address requester) {
        if (isRequestSubmited[productId][requester])
            revert AlreadyRequested(requester, productId);
        _;
    }

    modifier requestExists(uint256 requestId) {
        if (affiliateRequests[requestId].publisher == address(0))
            revert RequestDoesntExist(requestId);
        _;
    }

    modifier isConfirmed(uint256 requestId) {
        if (!affiliateRequests[requestId].isConfirmed)
            revert RequestNotConfirmed(requestId);
        _;
    }

    modifier notConfirmed(uint256 requestId) {
        if (affiliateRequests[requestId].isConfirmed)
            revert RequestAlreadyConfirmed(requestId);
        _;
    }

    modifier productExists(uint256 productId) {
        if (products[productId].nftAddress == address(0))
            revert ProductDoesntExist(productId);
        _;
    }

    modifier productDoesntExists(Product memory __product) {
        uint256 __productId = getProductId(__product);
        if (products[__productId].nftAddress != address(0))
            revert ProductExists(__productId);
        _;
    }

    modifier isManager(address manager) {
        if (!managers[manager]) revert AccessDenied();
        _;
    }

    constructor(
        string memory _shopName,
        string memory _shopAddress,
        address _shopOwner,
        string memory _shopLogo,
        string memory _shopDescription
    ) Ownable(_shopOwner) {
        shopInfo.shopName = _shopName;
        shopInfo.shopAddress = _shopAddress;
        shopInfo.shopOwner = _shopOwner;
        shopInfo.shopLogo = _shopLogo;
        shopInfo.shopDescription = _shopDescription;
        managers[DROPLINKED_MANAGER_WALLET] = true;
    }

    function transferManagerShip(
        address newManager
    ) external isManager(msg.sender) {
        managers[newManager] = true;
        managers[msg.sender] = false;
    }

    function setManager(address manager) external onlyOwner {
        managers[manager] = true;
    }

    function revokeManager(
        address manager
    ) external onlyOwner isManager(manager) {
        managers[manager] = false;
    }

    function getProductId(
        Product memory product
    ) public pure returns (uint256) {
        return
            uint256(keccak256(abi.encode(product.nftAddress, product.tokenId)));
    }

    function getProductIdV2(
        address nftAddress,
        uint256 tokenId
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(nftAddress, tokenId)));
    }

    function getShopName() external view returns (string memory) {
        return shopInfo.shopName;
    }

    function getShopAddress() external view returns (string memory) {
        return shopInfo.shopAddress;
    }

    function getShopOwner() external view returns (address) {
        return shopInfo.shopOwner;
    }

    function getShopLogo() external view returns (string memory) {
        return shopInfo.shopLogo;
    }

    function getShopDescription() external view returns (string memory) {
        return shopInfo.shopDescription;
    }

    function getProduct(
        uint256 productId
    ) external view returns (Product memory) {
        return products[productId];
    }

    function getProductViaAffiliateId(
        uint256 affiliateId
    ) external view returns (Product memory) {
        return products[affiliateRequests[affiliateId].productId];
    }

    function getProductCount() external view returns (uint256) {
        return productCount;
    }

    function mintAndRegisterBatch(
        RecordData[] calldata recordData
    ) public onlyOwner {
        uint256 len = recordData.length;
        for (uint256 i = 0; i < len; ) {
            mintAndRegister(recordData[i]);
            unchecked {
                ++i;
            }
        }
    }

    function mintAndRegister(
        RecordData memory mintData
    ) public onlyOwner returns (uint256 productId) {
        uint256 _tokenId = DroplinkedToken1155(mintData.nftAddress).mint(
            mintData.uri,
            mintData.amount,
            msg.sender,
            mintData.royalty,
            mintData.accepted
        );

        Product memory p = Product({
            nftAddress: mintData.nftAddress,
            tokenId: _tokenId,
            affiliatePercentage: mintData.affiliatePercentage,
            nftType: mintData.nftType,
            productType: mintData.productType
        });

        // register the product
        uint256 registeredProductId = registerProduct(p);

        emit ProductRegistered(
            registeredProductId,
            mintData.amount,
            msg.sender,
            mintData.uri
        );
        return registeredProductId;
    }

    function registerProduct(
        Product memory p
    ) public onlyOwner returns (uint256) {
        uint256 amount = 0;
        uint256 _productId = getProductId(p);
        if (products[_productId].nftAddress != address(0)) {
            // Product exists, we just want to add more to it
            if (p.nftType == NFTType.ERC721) {
                receivedProduct = false;
                amount = 1;
                IERC721(p.nftAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    p.tokenId
                );
                if (!receivedProduct) revert("NFT not received");
            } else if (p.nftType == NFTType.ERC1155) {
                receivedProduct = false;
                amount = IERC1155(p.nftAddress).balanceOf(
                    msg.sender,
                    p.tokenId
                );
                IERC1155(p.nftAddress).safeTransferFrom(
                    msg.sender,
                    address(this),
                    p.tokenId,
                    IERC1155(p.nftAddress).balanceOf(msg.sender, p.tokenId),
                    ""
                );
                if (!receivedProduct) revert("NFT not received");
            }
            return _productId;
        }

        products[_productId] = p;
        productCount++;
        if (p.nftType == NFTType.ERC721) {
            amount = 1;
            receivedProduct = false;
            IERC721(p.nftAddress).safeTransferFrom(
                msg.sender,
                address(this),
                p.tokenId
            );
            if (!receivedProduct) revert("NFT not received");
        } else if (p.nftType == NFTType.ERC1155) {
            receivedProduct = false;
            amount = IERC1155(p.nftAddress).balanceOf(msg.sender, p.tokenId);
            IERC1155(p.nftAddress).safeTransferFrom(
                msg.sender,
                address(this),
                p.tokenId,
                IERC1155(p.nftAddress).balanceOf(msg.sender, p.tokenId),
                ""
            );
            if (!receivedProduct) revert("NFT not received");
        }
        return _productId;
    }

    function unregisterProduct(
        uint256 productId
    ) external productExists(productId) onlyOwner nonReentrant {
        Product memory product = products[productId];
        delete products[productId];
        IERC721(product.nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            product.tokenId,
            ""
        );
        emit ProductUnregistered(productId, msg.sender);
    }

    function requestAffiliate(
        uint256 productId
    )
        external
        productExists(productId)
        notRequested(productId, msg.sender)
        returns (uint256)
    {
        uint256 requestId = affiliateRequestCount;
        affiliateRequests[requestId] = AffiliateRequest(
            msg.sender,
            productId,
            false
        );
        isRequestSubmited[productId][msg.sender] = true;
        affiliateRequestCount += 1;
        emit AffiliateRequested(requestId, productId, msg.sender);
        return requestId;
    }

    function approveRequest(
        uint256 requestId
    )
        external
        productExists(affiliateRequests[requestId].productId)
        requestExists(requestId)
        notConfirmed(requestId)
        onlyOwner
    {
        affiliateRequests[requestId].isConfirmed = true;
        emit AffiliateRequestApproved(requestId, msg.sender);
    }

    function disapproveRequest(
        uint256 requestId
    ) external requestExists(requestId) isConfirmed(requestId) onlyOwner {
        affiliateRequests[requestId].isConfirmed = false;
        AffiliateRequest memory aftemp = affiliateRequests[requestId];
        isRequestSubmited[aftemp.productId][aftemp.publisher] = false;
        emit AffiliateRequestDisapproved(requestId, msg.sender);
    }

    function getAffiliate(
        uint256 requestId
    ) external view returns (AffiliateRequest memory) {
        return affiliateRequests[requestId];
    }

    function getAffiliateRequestCount() external view returns (uint256) {
        return affiliateRequestCount;
    }

    // ------------------------------------------------------------------------------------------------------

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        receivedProduct = true;
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        receivedProduct = true;
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        revert("Shop does not support erc1155 batch transfer");
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function claimPurchase(
        address manager,
        bytes memory signature,
        PurchaseSignature memory purchaseSignature
    ) external isManager(manager) nonReentrant {
        PurchasedItem[] memory cart = purchaseSignature.cart;
        for (uint256 i = 0; i < cart.length; i++) {
            if (nullifiers[cart[i].nullifier]) {
                revert AlreadyClaimed();
            }
        }

        if (purchaseSignature.shop != address(this)) {
            revert("Invalid shop");
        }
        if (!verifyPurchase(manager, signature, purchaseSignature)) {
            revert("Invalid signature");
        }

        for (uint256 i = 0; i < cart.length; i++) {
            PurchasedItem memory item = cart[i];
            nullifiers[item.nullifier] = true;
            emit ProductClaimed(item.productId, msg.sender, item.amount);
        }

        for (uint256 i = 0; i < cart.length; i++) {
            PurchasedItem memory item = cart[i];
            if (products[item.productId].nftAddress == address(0)) {
                revert ProductDoesntExist(item.productId);
            }
            Product memory product = products[item.productId];
            if (product.nftType == NFTType.ERC721) {
                if (item.amount != 1) {
                    revert("Invalid amount");
                }
                // transfer to the caller
                IERC721(product.nftAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    product.tokenId,
                    ""
                );
            } else if (product.nftType == NFTType.ERC1155) {
                IERC1155(product.nftAddress).safeTransferFrom(
                    address(this),
                    msg.sender,
                    product.tokenId,
                    item.amount,
                    ""
                );
            }
        }
    }
}
