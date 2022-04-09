// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// A contract to change the ownership of your properties
contract PropertyProject {

    struct Property {
        address owner;
        uint id;
        string name;
        uint value;
        uint area;
    }

// all the properties listed for one particular address in an array,
// getter not required as tagged public
    mapping(address => Property[]) public properties;

// add your properties using this function
    function addProperties(
        uint _id,
        string calldata _name,
        uint _value,
        uint _area
    ) public {
        properties[msg.sender].push(Property(
            msg.sender, 
            _id,
            _name,
            _value,
            _area
        )); 
    }

// can change the ownership of one of your properties to another address
    function changePropertyOwner(uint _index, address _addr) public {
        // the properties of only the msg.sender will be checked.
        uint length = properties[msg.sender].length;
        properties[msg.sender][_index].owner = _addr;
        properties[_addr].push(properties[msg.sender][_index]);
        // delete properties[msg.sender][_index];
        // can replace the last property with the property to be deleted and then pop()
        properties[msg.sender][_index] = properties[msg.sender][length - 1];
        properties[msg.sender].pop();
    }
}
