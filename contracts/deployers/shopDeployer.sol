// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../base/Shop.sol";

contract DropShopDeployer is Ownable {
    constructor() Ownable(msg.sender) {}

    function deployShop(
        string memory _shopName,
        string memory _shopAddress,
        address _shopOwner,
        string memory _shopLogo,
        string memory _shopDescription
    ) public onlyOwner returns (address shop, address nftContract) {
        DropShop _shop = new DropShop(
            _shopName,
            _shopAddress,
            _shopOwner,
            _shopLogo,
            _shopDescription
        );
        // deploy the nft contract here
        return (address(_shop), address(0));
    }
}
