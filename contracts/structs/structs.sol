// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

enum PaymentMethodType{
    NATIVE_TOKEN,
    USD,
    TOKEN
}

struct PaymentInfo{
    PaymentMethodType paymentType;
    uint256 price;
    address currencyAddress;
}

struct Product{
    PaymentInfo paymentInfo;
    uint256 affiliatePercentage;
}

struct Affiliate{
    address producer;
    address publisher;
    uint256 productId;
    bool isConfirmed;
}

struct Beneficiary{
    bool isPercentage; 
    uint256 value;
    address wallet;
}