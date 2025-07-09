// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract ChainLinkTest {
    function getRoundData(
        uint80
    ) external view returns (uint256, int256, uint256, uint256, uint256) {
        return (1e8, 1e8, 1e8, block.timestamp, 1);
    }
}
