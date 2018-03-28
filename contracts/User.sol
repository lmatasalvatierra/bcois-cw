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
        OwnerDB(ownerdb).createOwner(indexUser, _email, _password, _name, _addressLine);
    }

    function loginOwner(bytes32 email, bytes32 password) senderIsManager public view
    returns (bool result) {
        address ownerdb = obtainDBContract('ownerDB');
        result = OwnerDB(ownerdb).login(email, password);
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

    function loginCarrier(bytes32 email, bytes32 password) senderIsManager public view
    returns (bool result) {
        address carriedb = obtainDBContract('carrierDB');
        result = CarrierDB(carriedb).login(email, password);
    }
}
