// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "./IERC20.sol";


// An private reward function which rewards user with 0.5% of new tokens on every transaction
contract testReward {

    error timeNotPassed(uint createTime);

    address immutable owner;

    // address array in blocklist, if suspected as a bot, to be added by the owner of the contract
    mapping(address => bool) blocklist;

    struct tokenDetails {
        uint amount;
        uint timestamp;
    }

    // address -> timestamp  -> amount 
    // mapping(address => mapping(uint => uint)) public tokenXAmount;
    mapping(address => tokenDetails[]) public tokenXAmount;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Not an owner");
        _;
    }

    function blockIfBot(address _toBlock) public onlyOwner {
        blocklist[_toBlock] = true;
    }

    // function to be called to claim the tokenX
    function claim(uint ID, address _tokenX) public {
        if (tokenXAmount[msg.sender][ID].amount > 0 &&
            block.timestamp >= tokenXAmount[msg.sender][ID].timestamp + 45 days) {
            uint amount = tokenXAmount[msg.sender][ID].amount;
            tokenXAmount[msg.sender][ID].amount = 0;
            bool sent = IERC20(_tokenX).transferFrom(address(this), msg.sender, amount);
            require(sent, "Token transfer failed");
        }
    }

    // get all your unclaimed IDs
    function getID() public view returns(uint[] memory Ids) {
        uint len = tokenXAmount[msg.sender].length;
        tokenDetails[] memory AllIds = tokenXAmount[msg.sender];
        uint num;
        for(uint i; i < len; i++ ) {
            if (AllIds[i].amount > 0) {
                Ids[num] = i;
                num++; 
            }    
        }
    }

    function reward(uint _amountIn, address _to, address tokenX, address owner1) public {
        require(_amountIn > 0, "amount shoudl be more than zero");
        require(_to != address(0), "address invalid");
        uint amount = _amountIn / 200;
        _transferX(_to, amount, tokenX, owner1);
    }

    function _transferX(address _to, uint _amount1, address tokenX, address owner1) private {
        require(
            IERC20(tokenX).allowance(owner1, address(this)) >= _amount1,
            "Token 1 allowance too low"
        );
        _safeTransferFrom(IERC20(tokenX), owner1, _to, _amount1);
    }

    function _safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) private {
        bool sent = token.transferFrom(sender, address(this), amount);
        require(sent, "Token transfer failed");
        if (sent) {
            tokenXAmount[recipient].push(tokenDetails(block.timestamp, amount));
        }
    }
}