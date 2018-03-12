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

    function setPermission(address _address, DataHelper.Permission _perm) senderIsManager public {
        address permdb = obtainDBContract("permDB");

        PermissionDB(permdb).setPermission(_address, _perm);
    }

    function getPermission(address _address) senderIsManager public view returns (DataHelper.Permission result) {
        address permdb = obtainDBContract("permDB");

        result = PermissionDB(permdb).getPermission(_address);
        return result;
    }

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
