// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// A contract to add your property details,
// to sell and change the ownership of your properties 
contract PropertyProject {

    struct Property {
        address owner;
        string name;
        uint value;
        uint area;
    }

// all the properties listed for one particular address in an array,
// getter not required as tagged public
    mapping(address => mapping(uint => Property)) public properties;

// events once amount is paid
    event paid(address, uint);

// add your property details using this function
    function addProperties(
        uint _id,
        string calldata _name,
        uint _value,
        uint _area
    ) public {
        properties[msg.sender][_id].owner = msg.sender;
        properties[msg.sender][_id].name = _name;
        properties[msg.sender][_id].value = _value;
        properties[msg.sender][_id].area = _area;
    }

// can change the ownership of one of your properties to another after the amount has been paid
    function changePropertyOwner(uint _id, address _addrtotransfer) public {
        Property memory propertyTransferred = properties[msg.sender][_id];
        require(propertyTransferred.owner == msg.sender, "not owner!");
        propertyTransferred.owner = _addrtotransfer;
        properties[_addrtotransfer][_id] = propertyTransferred;
        delete properties[msg.sender][_id];
    }

// pay the amount to the owner address by checking the value of the property
    function BuyProperty(address payable _ownerAddr, uint _id) public payable  {
        uint _amountToBePaid = properties[_ownerAddr][_id].value;
        require(msg.value == _amountToBePaid, "please pay according to the value of the property");
        _ownerAddr.transfer(msg.value);
        emit paid(_ownerAddr, msg.value);
    }
}
