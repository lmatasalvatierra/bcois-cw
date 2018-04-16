pragma solidity ^0.4.4;

import "./Database.sol";

contract UserDB is Database {

    mapping (bytes32 => bytes32) internal users;

    modifier onlyExistingUser(bytes32 email) {
        // Check if user exists or terminate

        require(!(users[email] == 0x0));
        _;
    }

    function login(bytes32 email, bytes32 password)
    public
    view
    onlyExistingUser(email)
    returns (bool) {
        return (users[email] == password);
    }
}
