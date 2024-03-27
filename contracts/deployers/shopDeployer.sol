// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../base/Shop.sol";
import "../tokens/erc1155.sol";

contract DropShopDeployer is Ownable {
    event ShopDeployed(address shop, address nftContract);
    event DroplinkedFeeUpdated(uint256 newFee);
    event HeartBeatUpdated(uint256 newHeartBeat);

    address[] public shopAddresses;
    address[] public nftContracts;
    uint256 public shopCount;
    uint256 public droplinkedFee = 100;
    uint256 public heartBeat;

    constructor(uint256 _heartBeat) Ownable(msg.sender) {
        heartBeat = _heartBeat;
    }

    function setDroplinkedFee(uint256 newFee) external onlyOwner() {
        droplinkedFee = newFee;
        emit DroplinkedFeeUpdated(newFee);
    }

    function setHeartBeat(uint256 newHeartBeat) external onlyOwner() {
        heartBeat = newHeartBeat;
        emit HeartBeatUpdated(newHeartBeat);
    }

    function deployShop(
        string memory _shopName,
        string memory _shopAddress,
        string memory _shopLogo,
        string memory _shopDescription
    ) public onlyOwner returns (address shop, address nftContract) {
        DropShop _shop = new DropShop(
            _shopName,
            _shopAddress,
            msg.sender,
            _shopLogo,
            _shopDescription,
            address(this)
        );
        // deploy the nft contract here
        DroplinkedToken token = new DroplinkedToken(address(this));
        nftContracts.push(address(token));
        shopAddresses.push(address(_shop));
        token.setMinter(address(_shop), true);
        shopCount++;
        emit ShopDeployed(address(_shop), address(token));
        return (address(_shop), address(token));
    }

    function getDroplinkedFee() view external returns(uint256) {
        return droplinkedFee;
    }

    function getHeartBeat() view external returns(uint256) {
        return heartBeat;
    }
}
