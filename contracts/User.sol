pragma solidity ^0.4.4;

import "./DougEnabled.sol";
import "./Doug.sol";
import "./UserDB.sol";
import "./OwnerDB.sol";

contract User is DougEnabled {

    mapping (bytes32 => uint) indexes;

    uint indexUser;

    // Owner Methods

    function createOwner(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _addressLine
    )
    public
    {
        address ownerdb = obtainDBContract('ownerDB');

        indexUser++;
        indexes[_email] = indexUser;
        OwnerDB(ownerdb).createOwner(indexUser, _email, _password, _name, _addressLine);
    }

    function loginOwner(bytes32 email, bytes32 password) public view
    returns (bool result) {
        address ownerdb = obtainDBContract('ownerDB');
        result = OwnerDB(ownerdb).login(email, password);
    }

    function addCertificate(bytes32 email, uint coi) public {
        address ownerdb = obtainDBContract('ownerDB');

        OwnerDB(ownerdb).addCertificate(indexes[email], coi);
    }

    function getOwner(bytes32 email)
    public
    view
    returns (bytes32 _email, bytes32 _name, bytes32 _addressLine, uint[20] _certificates)
    {
        address ownerdb = obtainDBContract('ownerDB');
        (_email, _name, _addressLine, _certificates) = OwnerDB(ownerdb).getOwner(indexes[email]);
        return (_email, _name, _addressLine, _certificates);
    }

    function getOwnerId(bytes32 email) public view returns (uint ownerId) {
        ownerId = indexes[email];
    }

    // Helper Methods

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
