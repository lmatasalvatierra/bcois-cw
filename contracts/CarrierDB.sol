pragma solidity ^0.4.4;

import "./UserDB.sol";

contract CarrierDB is UserDB {
    struct Carrier {
        bytes32 name;
        uint naicCode;
        bytes32 email;
    }

    mapping (uint => Carrier) carriers;

    function createCarrier(
        bytes32 _name,
        uint _naicCode,
        bytes32 _email,
        bytes32 _password
    )
    senderIsController("user")
    public
    {
        users[_email] = _password;
        Carrier storage carrier = carriers[_naicCode];
        carrier.name = _name;
        carrier.email = _email;
        carrier.naicCode = _naicCode;
    }

    function getCarrier(uint _naicCode)
    senderIsController("user")
    public
    view
    returns (bytes32, uint, bytes32)
    {
        return (carriers[_naicCode].name, carriers[_naicCode].naicCode, carriers[_naicCode].email);
    }
}
