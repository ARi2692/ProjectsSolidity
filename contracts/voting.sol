// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/// @title Voting Project 
/// @author Arundhati
/// @dev different parties will be involved, each voter can vote to anyone of the party as per their choice

contract Voting {

    //  party which want to stand for election
    struct party {
        address partyHead;
        string partyName;
        uint voteCount;
    }

    address public immutable chairman;

    // list of all parties
    party[] public parties;

    // individuals who will vote
    mapping(address => bool) public voted;

    event Start();
    event End(string winner, uint withVotes);

    uint public endAt;
    bool public started;
    bool public ended;

    constructor() {
        chairman = msg.sender;
    }

    // only chairman will create parties, start and end the voting process
    modifier onlyChairman() {
        require(chairman == msg.sender, "not the chairman");
        _;
    }   

    // all the parties can be registered by chairman using this function
    function createPartyList(address _partyHead, string calldata _partyname) public onlyChairman {
        require(!started, "started");
        parties.push(party( _partyHead, _partyname, 0));
    }

    // only the chairman can start the voting process
    function start() external onlyChairman {
        require(!started, "started");
        started = true;
        endAt = block.timestamp + 2 days;
        emit Start();
    }

    // each individual can vote only once 
    function voteToParty(uint _indexOfParty) public {
        require(!voted[msg.sender], "you have already voted");
        require(!ended, "Voting ended!");
        parties[_indexOfParty].voteCount++;
        voted[msg.sender] = true;
    }

    // only the chairman can end the voting process and get the winning party name and the count
    function getTheVoteCount() public onlyChairman returns(string memory _partyName, uint _voteCount) {
        require(started, "voting not started");
        require(block.timestamp >= endAt, "voting not ended");
        require(!ended, "ended");
        ended = true;
        for (uint i = 0; i < parties.length; i++) {
            if (parties[i].voteCount > _voteCount) {
                _voteCount = parties[i].voteCount;
                _partyName = parties[i].partyName;
            }
        }
        emit End(_partyName, _voteCount);
    }
}