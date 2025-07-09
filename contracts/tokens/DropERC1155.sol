// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../structs/Structs.sol";

contract DroplinkedToken is ERC1155, Ownable {
    event MintEvent(
        uint256 tokenId,
        address recipient,
        uint256 amount,
        string uri
    );
    event ManageWalletUpdated(address newManagedWallet);
    event FeeUpdated(uint256 newFee);
    event OperatorChanged(address newOperator);
    event MinterUpdated(address minter, bool state);

    address operatorContract;
    uint256 public totalSupply;
    uint256 public fee;
    string public constant name = "Droplinked";
    string public constant symbol = "DROP";
    uint256 public tokenCnt;
    address public managedWallet = 0x8c906310C5F64fe338e27Bd9fEf845B286d0fc1e;
    mapping(address => bool) public minterAddresses;
    mapping(uint256 => string) public uris;
    mapping(bytes32 => uint256) public tokenIdByHash;
    mapping(uint256 => uint256) public tokenCnts;
    mapping(uint256 => Issuer) public issuers;

    constructor(
        address droplinkedOperator_,
        address owner_
    ) ERC1155("") Ownable(owner_) {
        fee = 100;
        if (droplinkedOperator_ == address(0)) {
            revert("Operator address cannot be zero");
        }
        operatorContract = droplinkedOperator_;
        minterAddresses[operatorContract] = true;
    }

    modifier onlyOperator() {
        require(
            msg.sender == operatorContract,
            "Only the operator can call this contract"
        );
        _;
    }

    modifier onlyMinter() {
        require(
            minterAddresses[msg.sender],
            "Only Minters can call Mint Function"
        );
        _;
    }

    function changeOperator(
        address newOperatorContract_
    ) external onlyOperator {
        require(
            newOperatorContract_ != address(0),
            "New operator address cannot be zero"
        );
        operatorContract = newOperatorContract_;
        emit OperatorChanged(newOperatorContract_);
    }

    function setMinter(address minter_, bool state_) external onlyOperator {
        minterAddresses[minter_] = state_;
        emit MinterUpdated(minter_, state_);
    }

    function getOwnerAmount(
        uint256 tokenId,
        address owner_
    ) external view returns (uint256) {
        return balanceOf(owner_, tokenId);
    }

    function getTokenCnt() external view returns (uint256) {
        return tokenCnt;
    }

    function getTokenIdByHash(
        bytes32 metadataHash
    ) external view returns (uint256) {
        return tokenIdByHash[metadataHash];
    }

    function getTokenAmount(uint256 tokenId) external view returns (uint256) {
        return tokenCnts[tokenId];
    }

    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function uri(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return uris[tokenId];
    }

    function getManagedWallet() external view returns (address) {
        return managedWallet;
    }

    function setManagedWallet(address newManagedWallet_) external onlyOwner {
        require(
            newManagedWallet_ != address(0),
            "New managed wallet address cannot be zero"
        );
        managedWallet = newManagedWallet_;
        emit ManageWalletUpdated(newManagedWallet_);
    }

    function setFee(uint256 fee_) external onlyOperator {
        fee = fee_;
        emit FeeUpdated(fee_);
    }

    function getFee() external view returns (uint256) {
        return fee;
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner or approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        if (msg.sender != operatorContract) {
            require(
                from == _msgSender() || isApprovedForAll(from, _msgSender()),
                "ERC1155: caller is not token owner or approved"
            );
        }
        _safeTransferFrom(from, to, id, amount, data);
    }

    function getIssuer(uint256 tokenId) external view returns (Issuer memory) {
        return issuers[tokenId];
    }

    function mint(
        string calldata uri_,
        uint256 amount,
        address receiver,
        uint256 royalty,
        bool accepted
    ) external onlyMinter returns (uint256) {
        bytes32 metadata_hash = keccak256(abi.encode(uri_));
        uint256 tokenId = tokenIdByHash[metadata_hash];
        if (tokenId == 0) {
            tokenId = tokenCnt + 1;
            tokenCnt++;
            tokenIdByHash[metadata_hash] = tokenId;
            issuers[tokenId].issuer = receiver;
            issuers[tokenId].royalty = royalty;
        }
        totalSupply += amount;
        tokenCnts[tokenId] += amount;
        _mint(receiver, tokenId, amount, "");
        if (minterAddresses[msg.sender]) {
            _setApprovalForAll(receiver, msg.sender, true);
        }
        if (msg.sender == operatorContract) {
            _setApprovalForAll(receiver, operatorContract, true);
            if (accepted) _setApprovalForAll(receiver, managedWallet, true);
        }
        uris[tokenId] = uri_;
        emit URI(uri_, tokenId);
        emit MintEvent(tokenId, tx.origin, amount, uri_);
        return tokenId;
    }

    function droplinkedSafeBatchTransferFrom(
        address from,
        address[] memory to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external {
        for (uint256 i = 0; i < to.length; i++) {
            safeTransferFrom(from, to[i], ids[i], amounts[i], "");
        }
    }
}
