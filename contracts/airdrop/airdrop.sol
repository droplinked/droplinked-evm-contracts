// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @dev Minimal interfaces to reduce code size.
 *      (These are still valid runtime calls in Solidity 0.8.x)
 */
interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IERC1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

/**
 * @title BulkTokenDistributor
 * @dev Highly optimized version for gas efficiency.
 */
contract BulkTokenDistributor {
    // Custom error to save gas vs. revert strings
    error ArrayLengthMismatch();

    event AirdropDone(string airdropId);

    /**
     * @dev Distributes ERC20 tokens to multiple recipients.
     * @param token The ERC20 contract address
     * @param recipients The array of recipient addresses
     * @param amounts The array of amounts to send
     *
     * Requirements:
     * - recipients.length == amounts.length
     * - The caller must have approved this contract for enough tokens.
     */
    function distributeERC20(
        address token,
        address[] calldata recipients,
        uint256[] calldata amounts,
        string memory memo
    ) external {
        uint256 len = recipients.length;
        if (len != amounts.length) revert ArrayLengthMismatch();

        IERC20 erc20 = IERC20(token);

        emit AirdropDone(memo);

        for (uint256 i; i < len; ) {
            // Transfer from the caller to each recipient
            require(
                erc20.transferFrom(msg.sender, recipients[i], amounts[i]),
                "Transfer failed"
            );
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Distributes ERC721 tokens to multiple recipients.
     * @param token The ERC721 contract address
     * @param recipients The array of recipient addresses
     * @param tokenIds The array of token IDs to send
     *
     * Requirements:
     * - recipients.length == tokenIds.length
     * - The caller must own or be approved for each token ID.
     */
    function distributeERC721(
        address token,
        address[] calldata recipients,
        uint256[] calldata tokenIds,
        string memory memo
    ) external {
        uint256 len = recipients.length;
        if (len != tokenIds.length) revert ArrayLengthMismatch();

        IERC721 erc721 = IERC721(token);
        emit AirdropDone(memo);

        for (uint256 i; i < len; ) {
            // If you need the safety check, replace with safeTransferFrom
            erc721.safeTransferFrom(msg.sender, recipients[i], tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Distributes ERC1155 tokens to multiple recipients.
     * @param token The ERC1155 contract address
     * @param tokenId The token ID to distribute
     * @param recipients The array of recipient addresses
     * @param amounts The amount of tokens to send each recipient
     *
     * Requirements:
     * - The caller must have approved this contract as an operator (setApprovalForAll).
     */
    function distributeERC1155(
        address token,
        uint256 tokenId,
        address[] memory recipients,
        uint256[] memory amounts,
        string memory memo
    ) external {
        IERC1155 erc1155 = IERC1155(token);
        uint256 len = recipients.length;

        emit AirdropDone(memo);

        for (uint256 i; i < len; ) {
            erc1155.safeTransferFrom(
                msg.sender,
                recipients[i],
                tokenId,
                amounts[i],
                ""
            );
            unchecked {
                ++i;
            }
        }
    }
}
