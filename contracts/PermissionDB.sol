pragma solidity ^0.4.4;

import "./DataHelper.sol";
import "./DougEnabled.sol";
import "./Doug.sol";

contract PermissionDB is DougEnabled{
    struct Permit {
        address agency;
        address owner;
        address[10] guests;
        uint numGuests;
    }

    mapping (bytes32 => Permit) permissions;

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("perm");
        require (msg.sender == _contractAddress);
        _;
    }

    function setPermission(bytes32 policyNumber, address _agency, address _owner) senderIsController public {
        Permit storage permit = permissions[policyNumber];
        permit.agency = _agency;
        permit.owner = _owner;
        permit.numGuests = 0;
    }

    function getPermission(bytes32 policyNumber) senderIsController public view returns(address, address, address[10]) {
        return (permissions[policyNumber].agency, permissions[policyNumber].owner, permissions[policyNumber].guests);
    }

    function addGuest(address guest, bytes32 policyNumber) senderIsController public {
        Permit storage permit = permissions[policyNumber];
        permit.guests[permit.numGuests] =  guest;
        permit.numGuests++;
    }
}
