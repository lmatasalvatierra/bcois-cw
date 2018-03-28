pragma solidity ^0.4.4;

import "./Controller.sol";
import "./UserDB.sol";
import "./OwnerDB.sol";
import "./CarrierDB.sol";

contract User is Controller {

    mapping (bytes32 => uint) indexes;

    uint indexUser;

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

    function getOwnerId(bytes32 email) senderIsManager public view returns (uint ownerId) {
        ownerId = indexes[email];
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
        CarrierDB(carrierdb).createCarrier(_email, indexUser, _password, _name );
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
