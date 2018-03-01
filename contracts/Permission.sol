pragma solidity ^0.4.4;

import "./DataHelper.sol";
import "./DougEnabled.sol";
import "./Doug.sol";
import "./PermissionDB.sol";

contract Permission is DougEnabled{
    function setPermission(address _address, DataHelper.Permission _perm) public {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address permdb = Doug(DOUG).getContract("permDB");
        require (permdb != 0x0);

        PermissionDB(permdb).setPermission(_address, _perm);
    }

    function getPermission(address _address) public view returns (DataHelper.Permission result) {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address permdb = Doug(DOUG).getContract("permDB");
        require (permdb != 0x0);

        result = PermissionDB(permdb).getPermission(_address);
        return result;
    }
}
