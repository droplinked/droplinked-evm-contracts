// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

enum PaymentMethodType{
    NATIVE_TOKEN,
    USD,
    TOKEN
}

struct Beneficiary{
    bool isPercentage; 
    uint256 value;
    address wallet;
}

struct PaymentInfo{
    PaymentMethodType paymentType;
    uint256 price;
    address currencyAddress;
    Beneficiary[] beneficiaries;
}

struct Product{
    address nftAddress;
    uint256 tokenId;
    PaymentInfo paymentInfo;
    uint256 affiliatePercentage;
}

struct AffiliateRequest{
    address publisher;
    uint256 productId;
    bool isConfirmed;
}