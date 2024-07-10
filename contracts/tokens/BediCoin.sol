// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract BediCoin is ERC20, Ownable {
    
    mapping (address => bool) public blocked;
    mapping (address => bool) public minters;

    modifier notBlocked(address account) {
        require(!blocked[account]);
        _;
    }

    modifier isMinter(address account) {
        require(minters[account]);
        _;
    }

    constructor(uint initialSupply) ERC20("BediCoin", "BDC") Ownable(msg.sender){
        minters[msg.sender] = true;
        mint(msg.sender, initialSupply);
    }

    function blockAccount(address account) public onlyOwner {
        blocked[account] = true;
    }

    function unblockAccount(address account) public onlyOwner {
        blocked[account] = false;
    }

    function mint(address account, uint256 amount) public isMinter(msg.sender) notBlocked(account) {
        _mint(account, amount);
    }

    function transfer(address to, uint256 amount) public override notBlocked(msg.sender) notBlocked(to) returns(bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function addMinter(address account) public onlyOwner {
        minters[account] = true;
    }

    function removeMinter(address account) public onlyOwner {
        minters[account] = false;
    }

    function brun(uint256 amount) public isMinter(msg.sender) {
        _burn(msg.sender, amount);
    }
} 