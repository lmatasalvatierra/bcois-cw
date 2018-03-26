pragma solidity ^0.4.4;

import "./DougEnabled.sol";
import "./Doug.sol";

contract UserDB is DougEnabled {

    mapping (bytes32 => bytes32) private users;

    modifier onlyExistingUser(bytes32 email) {
        // Check if user exists or terminate

        require(!(users[email] == 0x0));
        _;
    }

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("user");
        require (msg.sender == _contractAddress);
        _;
    }

    function login(bytes32 email, bytes32 password) constant
    public
    senderIsController()
    onlyExistingUser(email)
    returns (bool) {
        return (users[email] == password);
    }

    function signUp(bytes32 email, bytes32 password) senderIsController() public {
        // Check if user exists.
        // If yes, return user name.
        // If no, check if name was sent.
        // If yes, create and return user.
        if (users[email] == 0x0)
        {
            users[email] = password;
        }
    }

    function update(bytes32 email, bytes32 password)
    public
    senderIsController()
    onlyExistingUser(email) {
        // Update user name.

        if (users[email] != 0x0)
        {
            users[email] = password;
        }
    }
}
