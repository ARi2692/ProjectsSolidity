
// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.1/contracts/token/ERC20/ERC20.sol";

// to mint tokenx 
contract TokenX is ERC20 {
    constructor(uint256 initialSupply, string memory name, string memory symbol)  ERC20(name, symbol) public {
        _mint(msg.sender, initialSupply);
    }
}