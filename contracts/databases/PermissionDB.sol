pragma solidity ^0.4.23;

import "./DataHelper.sol";
import "./Database.sol";

contract PermissionDB is Database{
    struct Permit {
        address agency;
        address owner;
        address[10] guests;
        uint numGuests;
    }

    mapping (bytes32 => Permit) permissions;

    function setPermission(bytes32 policyNumber, address _agency, address _owner) senderIsController("perm") public {
        Permit storage permit = permissions[policyNumber];
        permit.agency = _agency;
        permit.owner = _owner;
        permit.numGuests = 0;
    }

    function getPermission(bytes32 policyNumber) senderIsController("perm") public view returns(address, address, address[10]) {
        return (permissions[policyNumber].agency, permissions[policyNumber].owner, permissions[policyNumber].guests);
    }

    function addGuest(address guest, bytes32 policyNumber) senderIsController("perm") public {
        Permit storage permit = permissions[policyNumber];
        permit.guests[permit.numGuests] =  guest;
        permit.numGuests++;
    }
}
