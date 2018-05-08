pragma solidity ^0.4.23;

import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/UserDB.sol";
import "../databases/OwnerDB.sol";
import "../databases/CarrierDB.sol";
import "../databases/BrokerDB.sol";

contract User is Controller {

    mapping (bytes32 => uint) indexes;
    mapping (bytes32 => DataHelper.UserType) userTypes;

    uint indexUser;

    function getUserCredentials(bytes32 email) public view returns (uint, DataHelper.UserType) {
        return (indexes[email],userTypes[email]);
    }

    function login(bytes32 email, bytes32 _passwordHash) senderIsManager public view
    returns (uint, DataHelper.UserType) {
        bool userExists;
        DataHelper.UserType userType;
        uint userId;
        (userId, userType) = getUserCredentials(email);
        if(userType == DataHelper.UserType.Owner){
            address ownerdb = obtainDBContract('ownerDB');
            userExists = OwnerDB(ownerdb).login(email, _passwordHash);
            assert(userExists);
            return (userId, userType);
        } else if(userType == DataHelper.UserType.Carrier){
            address carrierdb = obtainDBContract('carrierDB');
            userExists = CarrierDB(carrierdb).login(email, _passwordHash);
            assert(userExists);
            return (userId, userType);
        } else if(userType == DataHelper.UserType.Broker){
            address brokerdb = obtainDBContract('brokerDB');
            userExists = BrokerDB(brokerdb).login(email, _passwordHash);
            assert(userExists);
            return (userId, userType);
        }
        return;
    }

    // Owner Methods

    function createOwner(
        bytes32 _email,
        string _password,
        bytes32 _name,
        bytes32 _addressLine
    )
    senderIsManager
    public
    {
        address ownerdb = obtainDBContract('ownerDB');

        indexUser++;
        indexes[_email] = indexUser;
        userTypes[_email] = DataHelper.UserType.Owner;
        OwnerDB(ownerdb).createOwner(indexUser, _email, _password, _name, _addressLine);
    }

    function addCertificate(bytes32 email, uint coi) senderIsManager public {
        address ownerdb = obtainDBContract('ownerDB');

        OwnerDB(ownerdb).addCertificate(indexes[email], coi);
    }

    function getOwner(bytes32 email)
    senderIsManager
    public
    view
    returns (uint, bytes32 _email, bytes32 _name, bytes32 _addressLine, uint[20] _certificates)
    {
        address ownerdb = obtainDBContract('ownerDB');
        (_email, _name, _addressLine, _certificates, ) = OwnerDB(ownerdb).getOwner(indexes[email]);

        return (indexes[_email], _email, _name, _addressLine, _certificates);
    }

    function getOwner(uint _ownerId)
    senderIsManager
    public
    view
    returns (bytes32 _email, bytes32 _name, bytes32 _addressLine)
    {
        address ownerdb = obtainDBContract('ownerDB');
        (_email, _name, _addressLine, ,) = OwnerDB(ownerdb).getOwner(_ownerId);
        return (_email, _name, _addressLine);
    }

    function getOwnerCertificates(uint _ownerId)
    senderIsManager
    public
    view
    returns (uint[20] certificates, uint numCertificates)
    {
        address ownerdb = obtainDBContract('ownerDB');
        (, , , certificates, numCertificates) = OwnerDB(ownerdb).getOwner(_ownerId);
        return (certificates, numCertificates);
    }

    // Carrier Methods

    function createCarrier(
        bytes32 _email,
        string _password,
        bytes32 _name
    )
    senderIsManager
    public
    {
        address carrierdb = obtainDBContract('carrierDB');

        indexUser++;
        indexes[_email] = indexUser;
        userTypes[_email] = DataHelper.UserType.Carrier;
        CarrierDB(carrierdb).createCarrier(_name, indexUser, _email, _password );
    }

    function getCarrier(bytes32 email)
    public
    view
    returns (bytes32 _name, uint _naicCode, bytes32 _email)
    {
        address carrierdb = obtainDBContract('carrierDB');

        (_name, _naicCode, _email) = CarrierDB(carrierdb).getCarrier(indexes[email]);
        return (_name, _naicCode, _email);
    }

    // Broker Methods

    function createBroker(
        bytes32 _email,
        string _password,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine
    )
    senderIsManager
    public
    {
        address brokerdb = obtainDBContract('brokerDB');

        indexUser++;
        indexes[_email] = indexUser;
        userTypes[_email] = DataHelper.UserType.Broker;
        BrokerDB(brokerdb).createBroker(indexUser, _email, _password, _name, _contactPhone, _addressLine );
    }

    function getBroker(bytes32 email)
    public
    view
    returns (bytes32 _name, bytes32 _email, bytes32 _contactPhone , bytes32 _addressLine)
    {
        address brokerdb = obtainDBContract('brokerDB');

        (_name, _email, _contactPhone, _addressLine) = BrokerDB(brokerdb).getBroker(indexes[email]);
        return (_name, _email, _contactPhone, _addressLine);
    }

    function getBroker(uint _brokerId)
    public
    view
    returns (bytes32 _name, bytes32 _email, bytes32 _contactPhone , bytes32 _addressLine)
    {
        address brokerdb = obtainDBContract('brokerDB');

        (_name, _email, _contactPhone, _addressLine) = BrokerDB(brokerdb).getBroker(_brokerId);
        return (_name, _email, _contactPhone, _addressLine);
    }
}
