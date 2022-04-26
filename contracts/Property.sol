// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/// @title Property Project 
/// @author Arundhati
/// @dev add your property details, sell it and change the ownership

contract PropertyProject {

    // property details 
    struct Property {
        address owner;
        string name;
        uint value;
        uint area;
    }

    // list of all the properties 
    Property[] public properties;

    // address mapped to the no of properties it own.
    mapping(address => uint) ownerPropertyCount;

    /** 
    * @dev Only the owner could add his property using this function
    * @param _name, the value of the property and the area of the property
    */
    function addProperties(
        string calldata _name,
        uint _value,
        uint _area
    ) public {
        properties.push(Property( msg.sender, _name, _value, _area ));
        ownerPropertyCount[msg.sender]++;
    }

    /** 
    * @dev list of all properties owned by a particular owner
    * @param _owner The owner address
    * @return List of all the properties of owner
    */ 
    function getPropertyByOwner(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerPropertyCount[_owner]);
        uint counter = 0;
        for(uint i = 0; i < properties.length; i++) {
            if(properties[i].owner == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    /**
    * @dev to change the owner of a property 
    * @param _id The property ID and _addrtotransfer The address of the new owner
    */
    function changePropertyOwner(uint _id, address _addrtotransfer) public {
        require(properties[_id].owner == msg.sender, "Not an owner");
        properties[_id].owner = _addrtotransfer;
        ownerPropertyCount[_addrtotransfer]++;
        ownerPropertyCount[msg.sender]--;
    }
}
