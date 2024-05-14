// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract FundsProxy is Ownable{
    ISwapRouter public router;
    address public USDC; // USDC token address

    constructor(address usdcTokenAddress, address routerAddress) Ownable(msg.sender) {
        changeUSDCAddress(usdcTokenAddress);
        setRouter(routerAddress);
    }

    function setRouter(address _router) public onlyOwner {
        require(_router != address(0), "Router address cannot be zero.");
        router = ISwapRouter(_router);
    }

    function changeUSDCAddress(address usdcTokenAddress) public onlyOwner{
        require(usdcTokenAddress != address(0), "Out-token cannot be zero.");
        USDC = usdcTokenAddress;
    }

    function convertAndSend(address tokenInput, address receiver) external {
        uint256 tokenAmount = IERC20(tokenInput).balanceOf(address(this));
        require(tokenAmount > 0, "Insufficient token balance.");

        // Approve the router to spend tokens
        IERC20(tokenInput).approve(address(router), tokenAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenInput,
            tokenOut: USDC,
            fee: 3000, // Pool fee (0.3% for most pools)
            recipient: receiver,
            deadline: block.timestamp,
            amountIn: tokenAmount,
            amountOutMinimum: 0, // Consider specifying minimum amount out
            sqrtPriceLimitX96: 0
        });

        // Perform the token swap on Uniswap
        uint256 amountOut = router.exactInputSingle(params);
        require(amountOut > 0, "Swap failed!");
    }
}