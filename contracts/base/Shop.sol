// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../interfaces/IDIP1.sol";
import "./BeneficiaryManager.sol";

/*

Done so far:
1. register product:
Each product has these attributes:
    uint256 tokenId;
    address nftAddress;
    PaymentInfo paymentInfo;
    uint256 affiliatePercentage; --> if this is zero, then the product is not affiliateable

Where Payment info contains information about the payment type, the currency address, the beneficiaries list.

*/

contract DropShop is IDIP1, BenficiaryManager, Ownable, IERC721Receiver {
    bool private receivedProduct;
    uint256 private receivedTokenId;
    address private receivedFrom;
    ShopInfo public _shopInfo;

    mapping(uint256 productId => Product product) public products;
    mapping(uint256 productId => mapping(address requester => bool))
        public isRequestSubmited;
    mapping(uint256 requestId => AffiliateRequest affiliateRequest)
        public affiliateRequests;
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
        if (affiliateRequests[requestId].isConfirmed == false)
            revert RequestNotConfirmed(requestId);
        _;
    }

    modifier notConfirmed(uint256 requestId) {
        if (affiliateRequests[requestId].isConfirmed == true)
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

    constructor(
        string memory _shopName,
        string memory _shopAddress,
        address _shopOwner,
        string memory _shopLogo,
        string memory _shopDescription
    ) Ownable(_shopOwner) {
        _shopInfo.shopName = _shopName;
        _shopInfo.shopAddress = _shopAddress;
        _shopInfo.shopOwner = _shopOwner;
        _shopInfo.shopLogo = _shopLogo;
        _shopInfo.shopDescription = _shopDescription;
    }

    function constructProduct(
        uint256 _tokenId,
        address _nftAddress,
        uint256 _affiliatePercentage,
        uint256 _price,
        address _currencyAddress,
        ProductType _productType,
        PaymentMethodType _paymentType,
        Beneficiary[] memory _beneficiaries
    ) private returns (Product memory) {
        uint[] memory _beneficiaryHashes = new uint[](_beneficiaries.length);
        for (uint i = 0; i < _beneficiaries.length; i++) {
            _beneficiaryHashes[i] = this.addBeneficiary(_beneficiaries[i]);
        }
        PaymentInfo memory paymentInfo = PaymentInfo(
            _price,
            _currencyAddress,
            _beneficiaryHashes,
            _paymentType
        );
        Product memory result = Product(
            _tokenId,
            _nftAddress,
            _productType,
            paymentInfo,
            _affiliatePercentage
        );
        return result;
    }

    function getProductId(
        Product memory product
    ) public pure returns (uint256) {
        return
            uint256(keccak256(abi.encode(product.nftAddress, product.tokenId)));
    }

    function getShopName() external view returns (string memory) {
        return _shopInfo.shopName;
    }

    function getShopAddress() external view returns (string memory) {
        return _shopInfo.shopAddress;
    }

    function getShopOwner() external view returns (address) {
        return _shopInfo.shopOwner;
    }

    function getShopLogo() external view returns (string memory) {
        return _shopInfo.shopLogo;
    }

    function getShopDescription() external view returns (string memory) {
        return _shopInfo.shopDescription;
    }

    function getProduct(
        uint256 productId
    ) external view returns (Product memory) {
        return products[productId];
    }

    function getProductCount() external view returns (uint256) {
        return productCount;
    }

    function getPaymentInfo(
        uint256 productId
    ) external view returns (PaymentInfo memory) {
        return products[productId].paymentInfo;
    }

    function registerProduct(
        uint256 _tokenId,
        address _nftAddress,
        uint256 _affiliatePercentage,
        uint256 _price,
        address _currencyAddress,
        ProductType _productType,
        PaymentMethodType _paymentType,
        Beneficiary[] memory _beneficiaries
    ) external onlyOwner returns (uint256) {
        Product memory __product = constructProduct(
            _tokenId,
            _nftAddress,
            _affiliatePercentage,
            _price,
            _currencyAddress,
            _productType,
            _paymentType,
            _beneficiaries
        );

        uint256 __productId = getProductId(__product);
        if (products[__productId].nftAddress != address(0))
            revert ProductExists(__productId);

        uint256 _productId = getProductId(__product);
        products[_productId] = __product;
        productCount++;
        receivedProduct = false;
        receivedTokenId = __product.tokenId;
        receivedFrom = __product.nftAddress;
        IERC721(__product.nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _productId
        );
        if (!receivedProduct) revert("NFT not received");
        emit ProductRegistered(_productId, msg.sender);
        return _productId;
    }

    function unregisterProduct(
        uint256 productId
    ) external productExists(productId) onlyOwner {
        Product memory product = products[productId];
        IERC721(product.nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            product.tokenId,
            ""
        );
        delete products[productId];
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

    // TODO : complete the purchase logic--------------------------------------------------------------------
    function purchaseProductFor(
        address receiver,
        uint256 productId,
        uint256 amount
    ) public {
        // TODO
    }
    function purchaseProduct(uint256 productId, uint256 amount) public {
        purchaseProductFor(msg.sender, productId, amount);
    }
    function purchaseAffiliateFor(
        address receiver,
        uint256 requestId,
        uint256 amount
    ) public {
        // TODO
    }
    function purchaseAffiliate(uint256 requestId, uint256 amount) public {
        purchaseAffiliateFor(msg.sender, requestId, amount);
    }
    // ------------------------------------------------------------------------------------------------------

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4) {
        receivedProduct = true;
        if (
            receivedTokenId != tokenId ||
            receivedFrom != from ||
            operator != address(this)
        ) revert("Not expecting this NFT");
        return this.onERC721Received.selector;
    }
}
