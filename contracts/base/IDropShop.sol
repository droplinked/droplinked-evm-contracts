// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../structs/structs.sol";

interface IDropShop {
    function _shopInfo()
        external
        view
        returns (
            string memory shopName,
            string memory shopAddress,
            string memory shopLogo,
            string memory shopDescription,
            address shopOwner
        );
    function affiliateRequestCount() external view returns (uint256);
    function affiliateRequests(
        uint256 requestId
    )
        external
        view
        returns (address publisher, uint256 productId, bool isConfirmed);
    function approveRequest(uint256 requestId) external;
    function beneficiaries(
        uint256
    ) external view returns (bool isPercentage, uint256 value, address wallet);
    function deployer() external view returns (address);
    function disapproveRequest(uint256 requestId) external;
    function getAffiliate(
        uint256 requestId
    ) external view returns (AffiliateRequest memory);
    function getAffiliateRequestCount() external view returns (uint256);
    function getProduct(
        uint256 productId
    ) external view returns (Product memory);
    function getProductCount() external view returns (uint256);
    function getProductId(
        Product memory product
    ) external pure returns (uint256);
    function getShopAddress() external view returns (string memory);
    function getShopDescription() external view returns (string memory);
    function getShopLogo() external view returns (string memory);
    function getShopName() external view returns (string memory);
    function getShopOwner() external view returns (address);
    function isRequestSubmited(
        uint256 productId,
        address requester
    ) external view returns (bool);
    function mintAndRegister(
        RecordData memory mintData
    ) external returns (uint256 productId);
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) external pure returns (bytes4);
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes memory data
    ) external returns (bytes4);
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4);
    function owner() external view returns (address);
    function paymentHelper(
        address from,
        address to,
        uint256 amount,
        Product memory product,
        uint256 ratio
    ) external;
    function productCount() external view returns (uint256);
    function products(
        uint256 productId
    )
        external
        view
        returns (
            uint256 tokenId,
            address nftAddress,
            uint8 nftType,
            uint8 productType,
            uint256 affiliatePercentage
        );
    function registerProduct(
        uint256 _tokenId,
        address _nftAddress,
        uint256 _affiliatePercentage,
        uint8 _nftType,
        uint8 _productType
    ) external returns (uint256);
    function renounceOwnership() external;
    function requestAffiliate(uint256 productId) external returns (uint256);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function transferOwnership(address newOwner) external;
    function unregisterProduct(uint256 productId) external;
}
