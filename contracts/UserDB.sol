pragma solidity ^0.4.4;

import "./DougEnabled.sol";
import "./Doug.sol";

contract UserDB is DougEnabled {

    mapping (bytes32 => bytes32) internal users;

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

    function login(bytes32 email, bytes32 password)
    public
    view
    senderIsController()
    onlyExistingUser(email)
    returns (bool) {
        return (users[email] == password);
    }
}
