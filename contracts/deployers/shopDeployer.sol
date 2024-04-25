// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IDIP1.sol";
import "../tokens/DropERC1155.sol";
import "../base/IDropShop.sol";

contract DropShopDeployer is Ownable {
    event ShopDeployed(address shop, address nftContract);
    event DroplinkedFeeUpdated(uint256 newFee);
    event HeartBeatUpdated(uint256 newHeartBeat);

    IDropShop[] public shopAddresses;
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
        bytes memory bytecode, bytes32 salt
    ) public onlyOwner returns (address shop, address nftContract) {
        address deployedShop;
        IDropShop _shop;
        assembly {
            deployedShop := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
            if iszero(extcodesize(deployedShop)) {
                revert(0, 0)
            }
        }
        _shop = IDropShop(deployedShop);
        DroplinkedToken token = new DroplinkedToken(address(this));
        shopOwners[msg.sender].push(deployedShop);
        nftOwners[msg.sender].push(address(token));
        nftContracts.push(address(token));
        shopAddresses.push(_shop);
        token.setMinter(deployedShop, true);
        shopCount++;
        emit ShopDeployed(deployedShop, address(token));
        return (deployedShop, address(token));
    }

    function getDroplinkedFee() external view returns (uint256) {
        return droplinkedFee;
    }

    function getHeartBeat() external view returns (uint256) {
        return heartBeat;
    }
}
