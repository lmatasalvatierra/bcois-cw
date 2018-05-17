pragma solidity ^0.4.23;

import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/UserDB.sol";
import "../databases/OwnerDB.sol";
import "../databases/CarrierDB.sol";
import "../databases/BrokerDB.sol";

contract User is Controller {

    function getUserCredentials(bytes32 email) senderIsManager public view returns (bytes16 userUUID, DataHelper.UserType userType) {
        address userdb = obtainDBContract('userDB');
        (userUUID, userType) = UserDB(userdb).getUserCredentials(email);
    }

    function login(bytes32 email, bytes32 _passwordHash) senderIsManager public view
    returns (bytes16 userUUID, DataHelper.UserType userType, bytes32 name) {
        address userdb = obtainDBContract('userDB');
        (userUUID, userType) = UserDB(userdb).login(email, _passwordHash);
        require(userUUID != 0, "User does not exist");
        if(userType == DataHelper.UserType.Owner) {
            address ownerdb = obtainDBContract('ownerDB');
            (, name, , ,) = OwnerDB(ownerdb).getOwner(userUUID);
        } else if(userType == DataHelper.UserType.Carrier) {
            address carrierdb = obtainDBContract('carrierDB');
            name = CarrierDB(carrierdb).getCarrier(userUUID);
        } else if(userType == DataHelper.UserType.Broker) {
            address brokerdb = obtainDBContract('brokerDB');
            (,name, , ) = BrokerDB(brokerdb).getBroker(userUUID);
        }
        return (userUUID, userType, name);
    }

    // Owner Methods

    function createOwner(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _addressLine,
        bytes16 _userUUID
    )
    senderIsManager
    public
    {
        address ownerdb = obtainDBContract('ownerDB');
        address userdb = obtainDBContract('userDB');

        UserDB(userdb).createUser(_email, _password, _userUUID, DataHelper.UserType.Owner);
        OwnerDB(ownerdb).createOwner(_userUUID, _email, _name, _addressLine);
    }

    function addCertificate(bytes16 _userUUID, uint coi) senderIsManager public {
        address ownerdb = obtainDBContract('ownerDB');

        OwnerDB(ownerdb).addCertificate(_userUUID, coi);
    }

    function getOwner(bytes16 _userUUID)
    senderIsManager
    public
    view
    returns (bytes32 _email, bytes32 _name, bytes32 _addressLine)
    {
        address ownerdb = obtainDBContract('ownerDB');

        (_email, _name, _addressLine, ,) = OwnerDB(ownerdb).getOwner(_userUUID);
        return (_email, _name, _addressLine);
    }

    function getOwnerCertificates(bytes16 _userUUID)
    senderIsManager
    public
    view
    returns (uint[20] certificates, uint numCertificates)
    {
        address ownerdb = obtainDBContract('ownerDB');
        (, , , certificates, numCertificates) = OwnerDB(ownerdb).getOwner(_userUUID);
        return (certificates, numCertificates);
    }

    // Carrier Methods

    function createCarrier(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes16 _userUUID
    )
    senderIsManager
    public
    {
        address carrierdb = obtainDBContract('carrierDB');
        address userdb = obtainDBContract('userDB');

        UserDB(userdb).createUser(_email, _password, _userUUID, DataHelper.UserType.Carrier);
        CarrierDB(carrierdb).createCarrier(_userUUID, _name);
    }

    // Broker Methods

    function createBroker(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine,
        bytes16 _userUUID
    )
    senderIsManager
    public
    {
        address brokerdb = obtainDBContract('brokerDB');
        address userdb = obtainDBContract('userDB');

        UserDB(userdb).createUser(_email, _password, _userUUID, DataHelper.UserType.Broker);
        BrokerDB(brokerdb).createBroker(_userUUID, _email, _name, _contactPhone, _addressLine);
    }

    function getBroker(bytes16 _brokerUUID) senderIsManager public view
        returns (bytes32 _name, bytes32 _contactPhone , bytes32 _addressLine)
    {
        address brokerdb = obtainDBContract('brokerDB');

        (,_name, _contactPhone, _addressLine) = BrokerDB(brokerdb).getBroker(_brokerUUID);
    }
}
