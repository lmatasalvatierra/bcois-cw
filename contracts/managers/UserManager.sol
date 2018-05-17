pragma solidity ^0.4.23;

import "../controllers/User.sol";
import "../libraries/DataHelper.sol";

contract UserManager {
    event LogCreateOwner(bytes32 name, bytes32 email, bytes32 addressLine);
    event LogCreateCarrier(bytes32 name, bytes32 email, bytes16 userUUID);
    event LogCreateBroker(bytes32 name, bytes32 email, bytes32 contactPhone, bytes32 addressLine);

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress);

    function login(bytes32 email, bytes32 _passwordHash) external view
    returns (bytes16 userUUID, DataHelper.UserType userType, bytes32 name) {
        address user = obtainControllerContract("user");
        (userUUID, userType, name) = User(user).login(email, _passwordHash);
    }

    function createOwner(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _addressLine,
        bytes16 _userUUID
    )
    external
    {
        address user = obtainControllerContract("user");

        User(user).createOwner(_email, _password, _name, _addressLine, _userUUID);
        emit LogCreateOwner(_name, _email, _addressLine);
    }

    function createCarrier(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes16 _userUUID
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createCarrier(_email, _password, _name, _userUUID);
        emit LogCreateCarrier(_name, _email, _userUUID);
    }

    function createBroker(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine,
        bytes16 _userUUID
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createBroker(_email, _password, _name, _contactPhone, _addressLine, _userUUID);
        emit LogCreateBroker(_name, _email, _contactPhone, _addressLine);
    }
}
