// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// This contract is a ETH wallet -
// which allows anyone to deposit funds but 
// only owner can withdraw funds from it

contract EthWallet {
    
    // The owner of the contract can withdraw the amount
    address payable private immutable owner;

    // An event to log if money is deposited 
    event logDeposit(address from, uint amount, address to);

    // A recieve function to receive the money
    receive() payable external {
        emit logDeposit(address(msg.sender), msg.value, address(this));
    }

    constructor () {
        owner = payable(msg.sender);
    }

    // modifier to check if the caller is owner
    modifier isOwner() {
        require(owner == msg.sender, "Only owner can access");
        _;
    }

    // function to check the balance which only owner can access
    function getBalance() public view isOwner returns (uint) {
        return address(this).balance;
    }

    // function to withdraw amount which only owner can access
    function withdraw(uint _amount) external payable isOwner {
        require(_amount <= address(this).balance, "Balance insufficient");
        payable(msg.sender).transfer(_amount);
    }
}
