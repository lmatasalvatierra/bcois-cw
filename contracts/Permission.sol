pragma solidity ^0.4.4;

import "./DataHelper.sol";
import "./DougEnabled.sol";
import "./Doug.sol";
import "./PermissionDB.sol";

contract Permission is DougEnabled{

    modifier senderIsManager() {
        address _contractAddress = Doug(DOUG).getContract("coiManager");
        require (msg.sender == _contractAddress);
        _;
    }

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

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }

    function isOwner(bytes32 policyNumber, address who, address permdb) senderIsManager private view returns (bool) {
        address _owner;
        (,  _owner,) = PermissionDB(permdb).getPermission(policyNumber);
        return (who == _owner);
    }
}
