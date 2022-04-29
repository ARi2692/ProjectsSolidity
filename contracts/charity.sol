// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title charity wallet Project 
/// @author Arundhati
/// @dev any one can send funds to the contract, but only owner can withdraw the amount stating the reason

contract CharityWallet {
    address payable immutable owner;
    event withdrawn(uint amount, string message);

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    function withdraw(uint _amount, string calldata _message) external onlyOwner {
        payable(msg.sender).transfer(_amount);
        emit withdrawn(_amount, _message);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}