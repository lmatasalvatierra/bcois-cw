pragma solidity ^0.4.23;

import "../DougEnabled.sol";
import "../controllers/User.sol";
import "../libraries/DataHelper.sol";

contract UserManager is DougEnabled {
    event LogCreateOwner(bytes32 name, bytes32 email, bytes32 addressLine);
    event LogCreateCarrier(bytes32 name, bytes32 email, uint naicCode);
    event LogCreateBroker(bytes32 name, bytes32 email, bytes32 contactPhone, bytes32 addressLine);

    function login(bytes32 email, bytes32 _passwordHash) public view
    returns (uint userId, DataHelper.UserType userType) {
        address user = obtainControllerContract("user");
        (userId, userType) = User(user).login(email, _passwordHash);
        return (userId, userType);
    }

    function createOwner(
        bytes32 _email,
        string _password,
        bytes32 _name,
        bytes32 _addressLine
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createOwner(_email, _password, _name, _addressLine);
        emit LogCreateOwner(_name, _email, _addressLine);
    }

    function addCertificate(bytes32 email, uint id) public {
        address user = obtainControllerContract("user");
        User(user).addCertificate(email, id);
    }

    function createCarrier(
        bytes32 _email,
        string _password,
        bytes32 _name
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createCarrier(_email, _password, _name);
        emit LogCreateCarrier(_name, _email, 1);
    }

    function createBroker(
        bytes32 _email,
        string _password,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createBroker(_email, _password, _name, _contactPhone, _addressLine);
        emit LogCreateBroker(_name, _email, _contactPhone, _addressLine); 
    }

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0, "Controller contract has not been deployed");
        return _contractAddress;
    }
}
