// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title charity wallet Project 
/// @author Arundhati
/// @dev any one can send funds to the contract, but only owner can withdraw the amount

contract CharityWallet {
    address payable immutable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    function withdraw(uint _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}