// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFundsProxy {
  function USDC (  ) external view returns ( address );
  function changeUSDCAddress ( address usdcTokenAddress ) external;
  function convertAndSend ( address tokenInput, address receiver ) payable external;
  function owner (  ) external view returns ( address );
  function renounceOwnership (  ) external;
  function router (  ) external view returns ( address );
  function setRouter ( address _router ) external;
  function transferOwnership ( address newOwner ) external;
}
