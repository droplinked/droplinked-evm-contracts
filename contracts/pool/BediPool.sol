// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IBediToken{
    function mint(address account, uint256 amount) external;
    function brun(uint256 amount) external;
}

contract BediPool is Ownable {
    IERC20 public bediToken;
    IERC20 public USDCToken;
    uint256 public rate = 100;

    constructor(address bediAddress, address usdcAddress) Ownable(msg.sender) {
        bediToken = IERC20(bediAddress);
        USDCToken = IERC20(usdcAddress);
    }

    function buyBedi(uint256 amount) public {
        USDCToken.transferFrom(msg.sender, address(this), amount * rate);
        IBediToken(address(bediToken)).mint(msg.sender, amount);
    }

    function sellBedi(uint256 amount) public {
        bediToken.transferFrom(msg.sender, address(this), amount);
        IBediToken(address(bediToken)).brun(amount);
        USDCToken.transfer(msg.sender, amount / rate);
    }
}