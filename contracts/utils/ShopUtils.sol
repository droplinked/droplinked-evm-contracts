// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IDropShop} from "../base/IDropShop.sol";
import {Product} from "../structs/Structs.sol";

contract TokenIdFetcher {
    function getTokenIds(
        address shopAddress,
        uint256[] calldata productIds
    ) external view returns (uint256[] memory tokenIds) {
        IDropShop shop = IDropShop(shopAddress);
        uint256 len = productIds.length;
        tokenIds = new uint256[](len);

        for (uint256 i = 0; i < len; i++) {
            Product memory p = shop.getProduct(productIds[i]);
            tokenIds[i] = p.tokenId;
        }
    }
}
