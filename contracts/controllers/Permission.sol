pragma solidity ^0.4.23;

import "../libraries/DataHelper.sol";
import "./Controller.sol";
import "../databases/PermissionDB.sol";

contract Permission is Controller{
    function setPermission(bytes32 policyNumber, address _agency, address _owner) senderIsManager public {
        address permdb = obtainDBContract("permDB");

        PermissionDB(permdb).setPermission(policyNumber, _agency, _owner);
    }

    function isPermittedToGetCoi(bytes32 policyNumber, address who) senderIsManager public view returns(bool result) {
        address permdb = obtainDBContract("permDB");
        address _agency;
        address _owner;
        address[10] memory _guests;
        result = false;
        (_agency,  _owner, _guests) = PermissionDB(permdb).getPermission(policyNumber);
        if(who == _agency || who == _owner){
            result = true;
        } else {
            for(uint i = 0; i < _guests.length; i++){
                if(who == _guests[i]){
                    result = true;
                    break;
                }
            }
        }
        return result;
    }

    function addGuest(address guest, bytes32 policyNumber, address owner) senderIsManager public {
        address permdb = obtainDBContract("permDB");

        if(isOwner(policyNumber, owner, permdb)){
            PermissionDB(permdb).addGuest(guest, policyNumber);
        } else {
            Status(101, "Not owner of COI");
            return;
        }
    }

    function isOwner(bytes32 policyNumber, address who, address permdb) senderIsManager private view returns (bool) {
        address _owner;
        (,  _owner,) = PermissionDB(permdb).getPermission(policyNumber);
        return (who == _owner);
    }
}
