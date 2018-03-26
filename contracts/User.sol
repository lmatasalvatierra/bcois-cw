pragma solidity ^0.4.4;

import "./DougEnabled.sol";
import "./Doug.sol";
import "./UserDB.sol";

contract User is DougEnabled {
    modifier onlyValidEmail(bytes32 email) {
        // Only valid names allowed

        require(!(email == 0x0));
        _;
    }

    function login(bytes32 email, bytes32 password) public view
    returns (bool result) {
        address userdb = obtainDBContract('userDB');
        result = UserDB(userdb).login(email, password);
    }

    function signUp(bytes32 email, bytes32 password) public returns (bytes32 result) {
        address userdb = obtainDBContract('userDB');
        result = UserDB(userdb).signUp(email, password);
    }

    function update(bytes32 email, bytes32 password) public
    onlyValidEmail(email)
    returns (bytes32 result) {
        address userdb = obtainDBContract('userDB');
        result = UserDB(userdb).update(email, password);
    }

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
