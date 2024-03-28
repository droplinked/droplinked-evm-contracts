// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

enum PaymentMethodType {
    NATIVE_TOKEN,
    USD,
    TOKEN
}

enum NFTType {
    ERC1155,
    ERC721
}

struct Beneficiary {
    bool isPercentage;
    uint256 value;
    address wallet;
}

struct PaymentInfo {
    uint256 price;
    address currencyAddress;
    uint256[] beneficiaries;
    PaymentMethodType paymentType;
}

struct Product {
    uint256 tokenId;
    address nftAddress;
    NFTType nftType;
    ProductType productType;
    PaymentInfo paymentInfo;
    uint256 affiliatePercentage;
}

struct AffiliateRequest {
    address publisher;
    uint256 productId;
    bool isConfirmed;
}

struct ShopInfo {
    string shopName;
    string shopAddress;
    string shopLogo;
    string shopDescription;
    address shopOwner;
}

enum ProductType {
    DIGITAL,
    POD,
    PHYSICAL
}