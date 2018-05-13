pragma solidity ^0.4.23;

import "./Database.sol";
import "../libraries/DataHelper.sol";

contract UserDB is Database {

    struct User {
        bytes32 email;
        bytes32 passwordHash;
        bytes16 userUUID;
        DataHelper.UserType userType;
    }

    mapping (bytes32 => User) internal users;

    modifier onlyExistingUser(bytes32 email) {
        // Check if user exists or terminate

        require(!(users[email].userUUID == 0x0), "User does not exist");
        _;
    }

    function createUser(
        bytes32 _email,
        bytes32 _passwordHash,
        bytes16 _userUUID,
        DataHelper.UserType _userType
    )
        senderIsController("user") public
    {
        User storage user = users[_email];
        user.email = _email;
        user.passwordHash = _passwordHash;
        user.userUUID = _userUUID;
        user.userType = _userType;
    }

    function login(bytes32 email, bytes32 _passwordHash)
    senderIsController("user") public
    view
    onlyExistingUser(email)
    returns (bytes16, DataHelper.UserType) {
        if(users[email].passwordHash == _passwordHash) {
            return (users[email].userUUID, users[email].userType);
        }
        else {
            return;
        }
    }

    function getUserCredentials(bytes32 email) senderIsController("user") public view
    returns (bytes16, DataHelper.UserType)
    {
        return (users[email].userUUID, users[email].userType);
    }
}
