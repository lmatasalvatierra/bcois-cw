pragma solidity ^0.4.4;

import "./UserDB.sol";

contract OwnerDB is UserDB{

    struct Owner {
        bytes32 email;
        bytes32 name;
        bytes32 addressLine;
        uint[20] certificates;
        uint numCertificates;
    }

    mapping (uint => Owner) owners;

    function createOwner(
        uint index,
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _addressLine
    )
    public
    {
        users[_email] = _password;
        Owner storage owner = owners[index];
        owner.email = _email;
        owner.name = _name;
        owner.addressLine = _addressLine;
    }

    function addCertificate(uint _owner, uint id) public {
        owners[_owner].certificates[owners[_owner].numCertificates] = id;
        owners[_owner].numCertificates++;
    }

    function getOwner(uint _owner)
    public
    view
    returns (bytes32, bytes32, bytes32, uint[20])
    {
        return (owners[_owner].email, owners[_owner].name, owners[_owner].addressLine, owners[_owner].certificates);
    }
}
