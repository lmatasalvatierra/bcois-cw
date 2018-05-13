pragma solidity ^0.4.23;

import "./Database.sol";

contract CarrierDB is Database {

    mapping (bytes16 => bytes32) carriers;

    function createCarrier(bytes16 _userUUID, bytes32 _name)
    senderIsController("user")
    public
    {
        carriers[_userUUID] = _name;
    }

    function getCarrier(bytes16 _userUUID) senderIsController("user")
    public
    view
    returns (bytes32)
    {
        return (carriers[_userUUID]);
    }
}
