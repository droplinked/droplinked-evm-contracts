// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDIP1.sol";
import "./BeneficiaryManager.sol";

contract DropShop is IDIP1, BenficiaryManager, Ownable {
    error AlreadyRequested(address requester, uint256 productId);
    error RequestDoesntExist(uint256 requestId);
    error RequestNotConfirmed(uint256 requestId);
    error RequestAlreadyConfirmed(uint256 requestId);

    string public shopName;
    string public shopAddress;
    address public shopOwner;
    string public shopLogo;
    string public shopDescription;
    mapping(uint256 productId => Product product) public products;
    mapping(uint256 productId => mapping(address requester => bool)) public isRequestSubmited;
    mapping(uint256 requestId => AffiliateRequest affiliateRequest) public affiliateRequests;
    uint256 public productCount;
    uint256 public affiliateRequestCount;

    modifier notRequested(uint256 productId, address requester) {
        if (isRequestSubmited[productId][requester]) revert AlreadyRequested(requester, productId);
        _;
    }

    modifier requestExists(uint256 requestId) {
        if (affiliateRequests[requestId].publisher == address(0)) revert RequestDoesntExist(requestId);
        _;
    }

    modifier isConfirmed(uint256 requestId){
        if (affiliateRequests[requestId].isConfirmed == false) revert RequestNotConfirmed(requestId);
        _;
    }

    modifier notConfirmed(uint256 requestId){
        if (affiliateRequests[requestId].isConfirmed == true) revert RequestAlreadyConfirmed(requestId);
        _;
    }
    
    constructor(string memory _shopName, string memory _shopAddress, address _shopOwner, string memory _shopLogo, string memory _shopDescription) Ownable(msg.sender) {
        shopName = _shopName;
        shopAddress = _shopAddress;
        shopOwner = _shopOwner;
        shopLogo = _shopLogo;
        shopDescription = _shopDescription;
    }

    function getShopName() external view returns (string memory){
        return shopName;
    }

    function getShopAddress() external view returns (string memory){
        return shopAddress;
    }

    function getShopOwner() external view returns (address){
        return shopOwner;
    }

    function getShopLogo() external view returns (string memory){
        return shopLogo;
    }

    function getShopDescription() external view returns (string memory){
        return shopDescription;
    }

    function getProduct(uint256 productId) external view returns (Product memory){
        return products[productId];
    }

    function getProductCount() external view returns (uint256){
        return productCount;
    }

    function getPaymentInfo(uint256 productId) external view returns (PaymentInfo memory){
        return products[productId].paymentInfo;
    }

    function registerProduct(Product memory product) external onlyOwner() returns(uint256){
        uint256 _productId = productCount;
        products[_productId] = product;
        productCount++;
        // transfer the NFT to shop
        // TODO
        //
        return _productId;
    }
    
    function unregisterProduct(uint256 productId) onlyOwner() external{
        delete products[productId];
        // transfer the NFT back
        // TODO
        // 
    }
    
    // TODO should this exist?
    function updateProductPrice(uint256 productId, uint256 price) onlyOwner() external{
        products[productId].paymentInfo.price = price;
    }
    
    function requestAffiliate(uint256 productId) external notRequested(productId, msg.sender) returns (uint256){
        uint256 requestId = affiliateRequestCount;
        affiliateRequests[requestId] = AffiliateRequest(msg.sender, productId, false);
        isRequestSubmited[productId][msg.sender] = true;
        affiliateRequestCount += 1;
        return requestId;
    }

    function approveRequest(uint256 requestId) requestExists(requestId) notConfirmed(requestId) onlyOwner() external{
        affiliateRequests[requestId].isConfirmed = true;
    }

    function disapproveRequest(uint256 requestId) requestExists(requestId) isConfirmed(requestId) onlyOwner() external{
        affiliateRequests[requestId].isConfirmed = false;
        AffiliateRequest memory aftemp = affiliateRequests[requestId];
        isRequestSubmited[aftemp.productId][aftemp.publisher] = false;
    }

    function getAffiliate(uint256 requestId) external view returns (AffiliateRequest memory){
        return affiliateRequests[requestId];
    }

    function getAffiliateRequestCount() external view returns (uint256){
        return affiliateRequestCount;
    }

    // TODO : complete the purchase logic
    function purchaseProductFor(address receiver, uint256 productId, uint256 amount) external{}
    function purchaseProduct(uint256 productId, uint256 amount) external{}
    function purchaseAffiliateFor(address receiver, uint256 requestId, uint256 amount) external{}
    function purchaseAffiliate(uint256 requestId, uint256 amount) external{}
}