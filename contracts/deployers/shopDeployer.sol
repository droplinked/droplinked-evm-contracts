// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../interfaces/IDIP1.sol";
import "../tokens/DropERC1155.sol";
import "../base/IDropShop.sol";

/**
 * @title DropShopDeployer
 * @dev Contract for deploying and managing drop shops and NFT contracts.
 */
contract DropShopDeployer is Initializable, OwnableUpgradeable {
    event ShopDeployed(address shop, address nftContract);
    event DroplinkedFeeUpdated(uint256 newFee);
    event HeartbeatUpdated(uint256 newHeartbeat);

    IDropShop[] public shopAddresses;
    address[] public nftContracts;
    mapping(address shopOwner => address[] shops) public shopOwners;
    mapping(address shopOwner => address[] nftContracts) public nftOwners;
    uint256 public droplinkedFee;
    uint256 public heartbeat;
    address public droplinkedWallet;
    uint256 public shopCount;

    function initialize(
        uint256 heartbeat_,
        address droplinkedWallet_,
        uint256 droplinkedFee_
    ) public initializer {
        __Ownable_init(msg.sender);
        require(
            droplinkedWallet_ != address(0),
            "Droplinked wallet cannot be zero address"
        );
        heartbeat = heartbeat_;
        droplinkedWallet = droplinkedWallet_;
        droplinkedFee = droplinkedFee_;
        emit HeartbeatUpdated(heartbeat_);
        emit DroplinkedFeeUpdated(droplinkedFee_);
    }

    function setDroplinkedFee(uint256 newFee) external onlyOwner {
        droplinkedFee = newFee;
        emit DroplinkedFeeUpdated(newFee);
    }

    function setHeartbeat(uint256 newHeartbeat) external onlyOwner {
        heartbeat = newHeartbeat;
        emit HeartbeatUpdated(newHeartbeat);
    }

    function deployShop(
        bytes memory bytecode,
        bytes32 salt
    ) external returns (address shop, address nftContract) {
        address deployedShop;
        IDropShop _shop;
        assembly {
            deployedShop := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
            if iszero(extcodesize(deployedShop)) {
                revert(0, 0)
            }
        }
        _shop = IDropShop(deployedShop);
        DroplinkedToken token = new DroplinkedToken(address(this), msg.sender);
        shopOwners[msg.sender].push(deployedShop);
        nftOwners[msg.sender].push(address(token));
        nftContracts.push(address(token));
        shopAddresses.push(_shop);
        ++shopCount;
        emit ShopDeployed(deployedShop, address(token));
        token.setMinter(deployedShop, true);
        return (deployedShop, address(token));
    }

    function getDroplinkedFee() external view returns (uint256) {
        return droplinkedFee;
    }

    function getHeartbeat() external view returns (uint256) {
        return heartbeat;
    }
}
