// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./ISwapRouter.sol";

contract SwapRouter is ISwapRouter {
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut){
        return params.amountIn;
    }
}