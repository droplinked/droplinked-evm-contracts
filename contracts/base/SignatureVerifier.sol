// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../structs/structs.sol";

contract SignatureVerifier {
    function verifyPurchase(
        address signer,
        bytes memory signature,
        PurchasedItem[] memory data
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(data);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        address _signer = recoverSigner(ethSignedMessageHash, signature);
        return _signer == signer;
    }

    function getMessageHash(
        PurchasedItem[] memory data
    ) public pure returns (bytes32) {
        // Encode the array of structs using abi.encode
        return keccak256(abi.encode(data));
    }

    function getEthSignedMessageHash(
        bytes32 messageHash
    ) public pure returns (bytes32) {
        // Recreates the message hash signed by the wallet
        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    messageHash
                )
            );
    }

    function recoverSigner(
        bytes32 ethSignedMessageHash,
        bytes memory signature
    ) public pure returns (address) {
        // Splits the signature into r, s, and v components
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(signature);
        // Recovers the signer's address
        return ecrecover(ethSignedMessageHash, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "Invalid signature length");

        assembly {
            // First 32 bytes after the length prefix
            r := mload(add(sig, 32))
            // Second 32 bytes
            s := mload(add(sig, 64))
            // Final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
