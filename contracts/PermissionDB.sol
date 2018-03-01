pragma solidity ^0.4.4;

import "./DataHelper.sol";
import "./DougEnabled.sol";
import "./Doug.sol";

contract PermissionDB is DougEnabled{
    mapping (address => DataHelper.Permission) permissions;

    function PermissionDB() public {
        permissions[msg.sender] = DataHelper.Permission.Admin;
    }

    function setPermission(address _address, DataHelper.Permission _perm) public {
        address perm = Doug(DOUG).getContract("perm");
        require (msg.sender == perm);
        permissions[_address] = _perm;
    }

    function getPermission(address _address) public view returns (DataHelper.Permission) {
        address perm = Doug(DOUG).getContract("perm");
        require (msg.sender == perm);
        return permissions[_address];
    }
}
