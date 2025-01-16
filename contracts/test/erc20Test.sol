// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DroplinkedERC20Token is ERC20 {
    constructor() ERC20("UsdCoin", "USDC") {
        _mint(msg.sender, 23000e18);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
