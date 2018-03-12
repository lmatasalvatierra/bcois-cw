pragma solidity ^0.4.4;

import "./DataHelper.sol";
import "./DougEnabled.sol";
import "./Doug.sol";

contract PermissionDB is DougEnabled{
    mapping (address => DataHelper.Permission) permissions;

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("perm");
        require (msg.sender == _contractAddress);
        _;
    }

    function PermissionDB() public {
        permissions[msg.sender] = DataHelper.Permission.Admin;
    }

    function setPermission(address _address, DataHelper.Permission _perm) senderIsController public {
        permissions[_address] = _perm;
    }

    function getPermission(address _address) senderIsController public view returns (DataHelper.Permission) {
        return permissions[_address];
    }
}
