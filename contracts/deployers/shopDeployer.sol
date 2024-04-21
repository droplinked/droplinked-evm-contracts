// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../base/Shop.sol";
import "../tokens/DropERC1155.sol";

contract DropShopDeployer is Ownable {
    event ShopDeployed(address shop, address nftContract);
    event DroplinkedFeeUpdated(uint256 newFee);
    event HeartBeatUpdated(uint256 newHeartBeat);

    address[] public shopAddresses;
    address[] public nftContracts;
    mapping(address shopOwner => address[] shops) public shopOwners;
    mapping(address shopOwner => address[] nftContracts) public nftOwners;
    uint256 public shopCount;
    uint256 public droplinkedFee = 100;
    uint256 public heartBeat;
    address public droplinkedWallet;

    constructor(uint256 _heartBeat) Ownable(msg.sender) {
        heartBeat = _heartBeat;
    }

    function setDroplinkedFee(uint256 newFee) external onlyOwner {
        droplinkedFee = newFee;
        emit DroplinkedFeeUpdated(newFee);
    }

    function setHeartBeat(uint256 newHeartBeat) external onlyOwner {
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
        DroplinkedToken token = new DroplinkedToken(address(this));
        shopOwners[msg.sender].push(address(_shop));
        nftOwners[msg.sender].push(address(token));
        nftContracts.push(address(token));
        shopAddresses.push(address(_shop));
        token.setMinter(address(_shop), true);
        shopCount++;
        emit ShopDeployed(address(_shop), address(token));
        return (address(_shop), address(token));
    }

    function getDroplinkedFee() external view returns (uint256) {
        return droplinkedFee;
    }

    function getHeartBeat() external view returns (uint256) {
        return heartBeat;
    }
}
