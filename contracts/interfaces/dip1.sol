// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IDIP1 {
    function getShopName() external view returns (string memory);
    function getShopAddress() external view returns (string memory);
    function getShopOwner() external view returns (address);
    function getShopLogo() external view returns (string memory);
    function getShopDescription() external view returns (string memory);
    
}