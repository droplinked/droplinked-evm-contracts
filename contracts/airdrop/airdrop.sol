// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title BulkTokenDistributor
 * @dev A contract for distributing ERC20, ERC721, and ERC1155 tokens to multiple recipients in bulk.
 */
contract BulkTokenDistributor {
    /**
     * @dev Distributes ERC20 tokens to multiple recipients
     * @param token Address of the ERC20 token contract
     * @param recipients Array of recipient addresses
     * @param amounts Array of amounts to send to each recipient
     * Requirements:
     * - Caller must have approved sufficient tokens to this contract
     * - recipients and amounts arrays must be of equal length
     */
    function distributeERC20(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(recipients.length == amounts.length, "Mismatched array lengths");
        IERC20 erc20 = IERC20(token);

        for (uint256 i = 0; i < recipients.length; i++) {
            erc20.transferFrom(msg.sender, recipients[i], amounts[i]);
        }
    }

    /**
     * @dev Distributes ERC721 tokens to multiple recipients
     * @param token Address of the ERC721 token contract
     * @param recipients Array of recipient addresses
     * @param tokenIds Array of token IDs to send to each recipient
     * Requirements:
     * - Caller must be owner of or approved for all tokens
     * - recipients and tokenIds arrays must be of equal length
     */
    function distributeERC721(
        address token,
        address[] calldata recipients,
        uint256[] calldata tokenIds
    ) external {
        require(recipients.length == tokenIds.length, "Mismatched array lengths");
        IERC721 erc721 = IERC721(token);

        for (uint256 i = 0; i < recipients.length; i++) {
            erc721.safeTransferFrom(msg.sender, recipients[i], tokenIds[i]);
        }
    }

    /**
     * @dev Distributes ERC1155 tokens to multiple recipients
     * @param token Address of the ERC1155 token contract
     * @param tokenId ID of the token to distribute
     * @param recipients Array of recipient addresses
     * @param amount Amount of tokens to send to each recipient
     * Requirements:
     * - Caller must have sufficient balance and approval
     */
    function distributeERC1155(
        address token,
        uint256 tokenId,
        address[] calldata recipients,
        uint256 amount
    ) external {
        IERC1155 erc1155 = IERC1155(token);

        for (uint256 i = 0; i < recipients.length; i++) {
            erc1155.safeTransferFrom(
                msg.sender,
                recipients[i],
                tokenId,
                amount,
                ""
            );
        }
    }
}
