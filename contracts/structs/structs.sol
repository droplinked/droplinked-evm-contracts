// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum NFTType {
    ERC1155,
    ERC721
}

struct Product {
    uint256 tokenId;
    address nftAddress;
    NFTType nftType;
    ProductType productType;
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

struct Issuer {
    address issuer;
    uint256 royalty;
}

struct RecordData {
    address nftAddress;
    string uri;
    uint256 amount;
    bool accepted;
    uint256 affiliatePercentage;
    uint256 royalty;
    NFTType nftType;
    ProductType productType;
}

struct PurchasedItem {
    uint256 amount;
    uint256 productId;
    uint256 nullifier;
}

struct PurchaseSignature {
    PurchasedItem[] cart;
    address shop;
}
