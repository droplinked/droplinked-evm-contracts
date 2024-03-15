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
    function getProductIds() external view returns (uint256[] memory);
    function getProductCount() external view returns (uint256);
    function supportsPayment(PaymentMethodType paymentType) external view returns (bool);
    function getPaymentInfo(uint256 productId) external view returns (PaymentInfo memory);
    function registerProduct(uint256 productId, Product memory product, uint256 price, PaymentInfo memory payment) external returns (bool);
    function unregisterProduct(uint256 productId) external returns (bool);
    function updateProductPrice(uint256 productId, uint256 price) external returns (bool);
    function affiliateRequest(uint256 productId) external returns (bool); 
}