// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../structs/structs.sol";

interface IDIP1 {
    function getShopName() external view returns (string memory);
    function getShopAddress() external view returns (string memory);
    function getShopOwner() external view returns (address);
    function getShopLogo() external view returns (string memory);
    function getShopDescription() external view returns (string memory);
    function getProduct(uint256 productId) external view returns (Product memory);
    function getProductCount() external view returns (uint256);
    function getPaymentInfo(uint256 productId) external view returns (PaymentInfo memory);
    function registerProduct(Product memory product) external returns(uint256);
    function unregisterProduct(uint256 productId) external;
    function updateProductPrice(uint256 productId, uint256 price) external;
    function requestAffiliate(uint256 productId) external returns (uint256);
    function approveRequest(uint256 requestId) external;
    function disapproveRequest(uint256 requestId) external;
    function getAffiliate(uint256 requestId) external view returns (AffiliateRequest memory);
    function getAffiliateRequestCount() external view returns (uint256);
    function purchaseProductFor(address receiver, uint256 productId, uint256 amount) external;
    function purchaseProduct(uint256 productId, uint256 amount) external;
    function purchaseAffiliateFor(address receiver, uint256 requestId, uint256 amount) external;
    function purchaseAffiliate(uint256 requestId, uint256 amount) external;
}