pragma solidity ^0.4.4;

import "./Controller.sol";
import "./DataHelper.sol";
import "./UserDB.sol";
import "./OwnerDB.sol";
import "./CarrierDB.sol";

contract User is Controller {

    mapping (bytes32 => uint) indexes;
    mapping (bytes32 => DataHelper.UserType) userTypes;

    uint indexUser;

    function getUserCredentials(bytes32 email) public view returns (uint, DataHelper.UserType) {
        return (indexes[email],userTypes[email]);
    }

    function login(bytes32 email, bytes32 password) senderIsManager public view
    returns (DataHelper.UserType result) {
        bool userExists;
        DataHelper.UserType user;
        (, user) = getUserCredentials(email);
        if(user == DataHelper.UserType.Owner){
            address ownerdb = obtainDBContract('ownerDB');
            userExists = OwnerDB(ownerdb).login(email, password);
            assert(userExists);
            return user;
        } else if(user == DataHelper.UserType.Carrier){
            address carrierdb = obtainDBContract('carrierDB');
            userExists = CarrierDB(carrierdb).login(email, password);
            assert(userExists);
            return user;
        }
        return;
    }

    // Owner Methods

    function createOwner(
        bytes32 _email,
        bytes32 _password,
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
    returns (bytes32 _email, bytes32 _name, bytes32 _addressLine, uint[20] _certificates)
    {
        address ownerdb = obtainDBContract('ownerDB');
        (_email, _name, _addressLine, _certificates) = OwnerDB(ownerdb).getOwner(indexes[email]);
        return (_email, _name, _addressLine, _certificates);
    }

    // Carrier Methods

    function createCarrier(
        bytes32 _email,
        bytes32 _password,
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
}
