// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

contract FundsProxy is Ownable{
    ISwapRouter public router;
    address public USDC;
    address public WETH;
    mapping (address tokenIn => uint24 poolFee) public poolFees;


    constructor(address usdcTokenAddress, address routerAddress, address nativeTokenWrapper) Ownable(msg.sender) {
        changeUSDCAddress(usdcTokenAddress);
        setRouter(routerAddress);
        setWETHAddress(nativeTokenWrapper);
        poolFees[0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c] = 100;
    }

    function setPoolFeeForToken(address tokenIn, uint24 poolFee) onlyOwner public{
        poolFees[tokenIn] = poolFee;
    }

    function setWETHAddress(address nativeTokenWrapper) onlyOwner public{
        require(nativeTokenWrapper != address(0), "WETH address cannot be zero!");
        WETH = nativeTokenWrapper;
    }

    function setRouter(address _router) public onlyOwner {
        require(_router != address(0), "Router address cannot be zero.");
        router = ISwapRouter(_router);
    }

    function changeUSDCAddress(address usdcTokenAddress) public onlyOwner{
        require(usdcTokenAddress != address(0), "Out-token cannot be zero.");
        USDC = usdcTokenAddress;
    }

    function convertAndSend(address tokenInput, address receiver) public payable{
        // conversion to wrapped etheruem for native tokens!
        if (msg.value != 0 && tokenInput != address(0)){
            // it put value and token input => panic
            revert ("Can't swap 2 assets in 1 call");
        }
        
        if (msg.value != 0){
            tokenInput = WETH;
            IWETH(WETH).deposit{value: msg.value}();
        }

        // start of swapping
        uint256 tokenAmount = IERC20(tokenInput).balanceOf(address(this));
        require(tokenAmount > 0, "Insufficient token balance.");

        // Approve the router to spend tokens
        IERC20(tokenInput).approve(address(router), tokenAmount);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: tokenInput,
            tokenOut: USDC,
            fee: poolFees[tokenInput],
            recipient: receiver,
            deadline: block.timestamp + 1,
            amountIn: tokenAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        // Perform the token swap on Uniswap
        uint256 amountOut = router.exactInputSingle(params);
        require(amountOut > 0, "Swap failed!");
    }
}