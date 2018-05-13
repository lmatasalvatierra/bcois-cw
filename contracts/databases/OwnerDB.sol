pragma solidity ^0.4.23;

import "./Database.sol";

contract OwnerDB is Database {

    struct Owner {
        bytes32 email;
        bytes32 name;
        bytes32 addressLine;
        uint[20] certificates;
        uint numCertificates;
    }

    mapping (bytes16 => Owner) owners;

    function createOwner(
        bytes16 _userUUID,
        bytes32 _email,
        bytes32 _name,
        bytes32 _addressLine
    )
    public
    {
        Owner storage owner = owners[_userUUID];
        owner.email = _email;
        owner.name = _name;
        owner.addressLine = _addressLine;
    }

    function addCertificate(bytes16 _userUUID, uint _certificateNumber) public {
        owners[_userUUID].certificates[owners[_userUUID].numCertificates] = _certificateNumber;
        owners[_userUUID].numCertificates++;
    }

    function getOwner(bytes16 _userUUID)
    public
    view
    returns (bytes32, bytes32, bytes32, uint[20], uint)
    {
        return (owners[_userUUID].email, owners[_userUUID].name, owners[_userUUID].addressLine, owners[_userUUID].certificates, owners[_userUUID].numCertificates);
    }
}
