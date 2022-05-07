// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

/// @title KYC Verification Process for Banks
/// @author Arundhati
/// @notice - To track money laundering activities by Central Bank and other government banks
/// @dev KYC - Banks can also add the new customer if allowed and do the KYC of the customers.
///          - banks are banned by the central bank from adding any new customer to do any more customer KYCs and should be sorted out first
///          - track which customer KYC is completed or pending along with customer details

contract KYC {

    // central bank admin will be the owner - who can add banks to the list
    address immutable owner;

    // bank details
    struct Bank {
        string name;
        uint256 kycCount;
        address Address;
        bool isAllowedToAddCustomer;
        bool kycPrivilege;
    }

    // customer details
    struct Customer {
        string name;
        string data;
        address validatedBank;
        bool kycStatus;
    }

    //  Mapping a bank's address to the Bank
    mapping(address => Bank) banks;

    // Mapping a customer's username to the Customer
    mapping(string => Customer) customersInfo;

    // Custom error when a particular customer doesnot exist.
    error customerDoesNotExist(string);

    // Custom error when a particular college is already blocked or unblocked and trying to block again. 
    error alreadyBlockedOrUnblocked(address);

    // Set the central bank Admin as the owner, who can add banks to the list
    constructor() {
        owner = msg.sender;
    }

    // Onlyadmin modifier is used to check if - Only bank Admin is adding the banks 
    modifier onlyadmin(){
        require(msg.sender == owner);
        _;
    }

    // to check if the bank names are same
    modifier sameName(string memory name1, string memory name2) {
        require(keccak256(bytes(name1)) != keccak256(bytes(name2)), "A Bank already exists with same name");
        _;
    }

    // tp check if a bank is allowed to add a customer
    modifier isAllowed(address _add) {
        require(banks[msg.sender].isAllowedToAddCustomer, "Requested Bank is blocked to add new customers");
        _;
    }

    //  customerExists modifier - to check if a customer in a bank exists or not
    modifier customerExists(string memory custName) {
        if(customersInfo[custName].validatedBank == address(0)) {
            revert customerDoesNotExist(custName);
        }
        _;
    }

    // blockedOrUnblocked Modifier is used to check if - a particular bank is already blocked or unblocked
    modifier blockedOrUnblocked(address _add, bool _allow) {
        if(banks[_add].isAllowedToAddCustomer == _allow) {
            revert alreadyBlockedOrUnblocked(msg.sender);
        }
        _;
    }

    // blockedOrUnblockedKYC Modifier is used to check if - a particular bank is already blocked or unblocked from KYC Privilege
    modifier blockedOrUnblockedKYC(address _add, bool _allow) {
        if(banks[_add].kycPrivilege == _allow) {
            revert alreadyBlockedOrUnblocked(msg.sender);
        }
        _;
    }
    

    // bankDoesNotExists modifier - to check is a bank exists or not
    modifier bankDoesNotExists(address _add) {
        require(banks[_add].Address != address(0), "Bank not found");
        _;
    }

    // event when a bank is added 
    event bankAdded(string, address indexed);
    // event when a customer is added to a particular bank
    event addedNewCustomer(address indexed, string indexed);
    // event when a bank address is blocked/unblocked from adding customer
    event blockedFromAddingCustomersOrNot(address indexed, string indexed);
    // event when a customer KYC is added to a particular bank
    event addedCustomerKyc(address indexed, string indexed);
    // event when a bank address is blocked/unblocked from adding KYC
    event bankKYC(address indexed, string indexed);

    /// @notice allows the central bank Admin to add bank to the list of bank
    /// @dev will check if bank already exists, and the details of the bank will be initialized.
    /// @param bankName - bank Name, add -  Address of the bank   
    function addNewBank(string calldata bankName, address add) external onlyadmin sameName(banks[add].name, bankName) {
        banks[add] = Bank(bankName, 0, add, true, true);
        emit bankAdded(bankName, add);
    }

    /// @notice allows the bank  to add a customer to the customer list
    /// @dev will check if bank is allowed to add a customer and whether the customer already exists
    /// @param custName - customer Name, custData -  customer data 
    function addNewCustomerToBank(string calldata custName, string calldata custData) external isAllowed(msg.sender) {
        require(customersInfo[custName].validatedBank == address(0), "Requested Customer already exists");
        customersInfo[custName] = Customer(custName, custData, msg.sender, false);
        emit addedNewCustomer(customersInfo[custName].validatedBank, custName);
    }

    /// @notice allows to add the KYC of a customer in a particular bank
    /// @dev will check if the particular bank has KYC Privilege or not
    /// @param custName - customer Name
    function addNewCustomerRequestForKYC(string calldata custName) customerExists(custName) external {
        require(banks[msg.sender].kycPrivilege, "Requested Bank does not have KYC Privilege");
        customersInfo[custName].kycStatus= true;
        banks[msg.sender].kycCount++;
        emit addedCustomerKyc(msg.sender, custName);
    }

    /// @notice Block the bank from adding new customers, can only be called by the central bank Admin 
    /// @dev will check if bank exists and whether the bank is already blocked or not
    /// @param add - Address of the bank to block from adding customers.
    function blockBankFromAddingNewCustomers(address add) external onlyadmin bankDoesNotExists(add) blockedOrUnblocked(add, false) {
        banks[add].isAllowedToAddCustomer = false;
        emit blockedFromAddingCustomersOrNot(add, "blocked");
    }

    /// @notice allow the bank from adding new customers, can only be called by the central bank Admin 
    /// @dev will check if bank exists and whether the bank is already unblocked or not
    /// @param add - Address of the bank to unblock from adding customers.
    function allowBankFromAddingNewCustomers(address add) external onlyadmin bankDoesNotExists(add) blockedOrUnblocked(add, true) {
        banks[add].isAllowedToAddCustomer = true;
        emit blockedFromAddingCustomersOrNot(add, "Unblocked");
    }

    /// @notice to block the kyc Permission of any of the banks 
    /// @dev will check if bank exists and whether the bank is already blocked or not
    /// @param add - Address of the bank to block from adding customers.
    function blockBankFromKYC(address add) external onlyadmin bankDoesNotExists(add) blockedOrUnblockedKYC(add, false) {
        banks[add].kycPrivilege = false;
        emit bankKYC(add, "blocked");
    }

    /// @notice to allow the kyc Permission of any of the blocked banks 
    /// @dev will check if bank exists and whether the bank is already blocked or not
    /// @param add - Address of the bank to allow from adding customers.
    function allowBankFromKYC(address add) external onlyadmin bankDoesNotExists(add) blockedOrUnblockedKYC(add, true) {
        banks[add].kycPrivilege = true;
        emit bankKYC(add, "allowed");
    }

    /// @notice Returns the a particular customer details, can be checked by anyone 
    /// @dev can get the customer details using the ID of the customer name
    /// @param custName - customer name
    /// @return customer details
    function viewCustomerData(string calldata custName) customerExists(custName) external view returns(string memory, bool){
        return (customersInfo[custName].data,customersInfo[custName].kycStatus);
    }

    /// @notice Returns the a particular customer KYC status, can be checked by anyone 
    /// @dev can get the customer details using the Name of the customer
    /// @param custName - customer name
    /// @return A boolean whether status set to true of false
    function getCustomerKycStatus(string calldata custName) customerExists(custName) external view returns(bool){
        return (customersInfo[custName].kycStatus);
    }

}