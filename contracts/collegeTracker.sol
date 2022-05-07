// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

/// @title college tracker Project
/// @author Arundhati
/// @notice - To track the colleges and the students enrolled in them, where the university can also track the illegal colleges
/// @dev collegeTracker - track all the colleges and the students, where the University Admin will be autorized to add colleges,
///                     - block and unblock a particular college from adding new students. This can be due to the college being illegal or having any complaints against it
///                     - Only the college admin will be able to add and update student details. 

contract collegeTracker {

    // University Admin will be the owner - who can add the colleges to the list
    address immutable owner;

    // student details
    struct student{
        string  sName;
        uint256 phoneNo;
        string  courseName;
    }

    // college details
    struct college {
        string collegeName;
        address add;
        address cAdmin;
        string regNo;
        bool allowedToAdd;
        uint nStudents;
    }

    // list of all the colleges
    college[] colleges; 

    // list of all students
    student[] students;

    // address of the college mapped to the location of college in the list of array of colleges.
    // Note - While trying to fetch the college details we used -> Index = location - 1, 
    //        as location will be the length of the array and not the index of the array.
    mapping(address => uint) collegeList; 
 
    // Custom error when a particular college is not allowed to add students. 
    // Notifies the address which tries to add a student in a blocked college.
    error notAllowedToAddStudents(address);

    // Custom error when a particular address is not the authorized person to access.
    error notAdmin(address);

    // Custom error when a particular college is already blocked or unblocked and trying to block again. 
    // Notifies the address which tries to again block or unblock college.
    error alreadyBlockedOrUnblocked(address);

    // Set the University Admin as the owner, who can add colleges to the list
    constructor(address _add) {
        owner = _add;
    }

    // OnlyAdmin modifier is used to check if -
    //      Only University Admin is adding the colleges 
    //      Only the college Admin to the respective colleges is adding the students to the college list 
    modifier onlyAdmin(address _admin) {
        if(msg.sender != _admin) {
            revert notAdmin(msg.sender);
        }
        _;
    }

    // allowed Modifier is used to check if - a particular college is allowed to add the students
    modifier allowed(address _add) {
        if(!colleges[collegeList[_add] - 1].allowedToAdd) {
            revert notAllowedToAddStudents(msg.sender);
        }
        _;
    }

    // blockedOrUnblocked Modifier is used to check if - a particular college is already blocked or unblocked
    modifier blockedOrUnblocked(address _add, bool _allow) {
        if(colleges[collegeList[_add] - 1].allowedToAdd == _allow) {
            revert alreadyBlockedOrUnblocked(msg.sender);
        }
        _;
    }

    // event when a college is added in the list
    event CollegeAdded(string, address indexed);
    // event when a student is added to a particular college
    event StudentAdded(address indexed, string indexed, string indexed, uint);
    // event when a address is blocked 
    event blocked(address indexed);
    // event when a address is blocked 
    event unblocked(address indexed);
    // event when a student of a particular college changes a course
    event courseChanged(address indexed, string indexed, string indexed, uint);

    /// @notice allows the University Admin to add college to the list of colleges
    /// @dev collegeList maps the address to corresponding location (index + 1) of the college in the array.
    /// @param _collegeName - College Name, _add -  Address of the college, _cAdmin - college Admin and _regNo - registration number
    function addNewCollege(string calldata _collegeName, address _add, address _cAdmin, string calldata _regNo) external onlyAdmin(owner) {       
        require(collegeList[_add] == 0, "College present");
        colleges.push(college({
            collegeName: _collegeName, 
            add: _add,
            cAdmin: _cAdmin,
            regNo: _regNo,
            allowedToAdd: true,
            nStudents: 0
        }));
        collegeList[_add]++;
        emit CollegeAdded(_collegeName, _add);
    }

    /// @notice allows the college admin to add a new student to the students list
    /// @dev will check if the college is allowed to add students and add the details of the student
    /// @param _add - College address of the student, _sName - student Name, _phoneNo - Phone number of student, _courseName - course Name of student.
    function addNewStudentToCollege(address _add, string calldata _sName, uint256 _phoneNo, string calldata _courseName) external onlyAdmin(colleges[collegeList[_add] - 1].cAdmin) allowed(_add) {
        students.push(student({
            sName: _sName,
            phoneNo: _phoneNo,
            courseName: _courseName
        }));
        colleges[collegeList[_add] - 1].nStudents++;
        emit StudentAdded(_add, _sName, _courseName, students.length);
    }

    /// @notice Block the college from adding new students, can only be called by the University Admin 
    /// @dev The index of college (collegeList[_add] - 1]) will be checked in the colleges array. blockedOrUnblocked modifier - checks if it is unblocked.
    /// @param _add - Address of the college to block from adding students.
    function blockCollegeToAddNewStudents(address _add) onlyAdmin(owner) external blockedOrUnblocked(_add, false) {        
        colleges[collegeList[_add] - 1].allowedToAdd = false;
        emit blocked(_add);
    }

    /// @notice Unblock the college from adding new students, can only be called by the University Admin 
    /// @dev The index of college (collegeList[_add] - 1]) will be checked in the colleges array. blockedOrUnblocked modifier - checks if it is blocked.
    /// @param _add - Address of the college to unblock from adding students.
    function unblockCollegeToAddNewStudents(address _add) onlyAdmin(owner) external blockedOrUnblocked(_add, true) {        
        colleges[collegeList[_add] - 1].allowedToAdd = true;
        emit unblocked(_add);
    }

    /// @notice allows the college admin to update the student's course
    /// @dev updates the student's course name 
    /// @param _add - College address of the student, _sID - student ID, _sName - student Name, _newCourse - course Name of student to be updated.
    function changeStudentCourse(address _add, uint _sID, string calldata _newCourse) external onlyAdmin(colleges[collegeList[_add] - 1].cAdmin) {
        students[_sID - 1].courseName = _newCourse;
        emit courseChanged(_add, students[_sID - 1].sName, _newCourse, _sID);
    }

    /// @notice Returns the number of students in a particular college, can be checked by anyone
    /// @dev The index of college (collegeList[_add] - 1]) will be checked in the colleges array, using which we can get the number of students
    /// @param _add - College address
    /// @return number of students in a particular college
    function getNumberOfStudentForCollege(address _add) external view returns(uint) {        
        return colleges[collegeList[_add] - 1].nStudents;
    }

    /// @notice Returns the a particular student details, can be checked by anyone 
    /// @dev can get the student details using the ID of the student
    /// @param _sID - Student ID
    /// @return Student details
    function viewStudentDetails(uint _sID) external view returns(student memory Student) {
        Student = students[_sID];
    }

    /// @notice Returns the a particular college details, can be checked by anyone if the college is banned or not
    /// @dev can get the college current details using the address of the college
    /// @param _add - College address
    /// @return College details
    function viewCollegeDetails(address _add) external view returns(college memory College) {
        College = colleges[collegeList[_add] - 1];
    }
}