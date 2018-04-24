pragma solidity ^0.4.4;

import "./UserDB.sol";

contract BrokerDB is UserDB {
    struct Broker {
        uint brokerId;
        bytes32 name;
        bytes32 email;
        bytes32 contactPhone;
        bytes32 addressLine;
    }

    mapping (uint => Broker) brokers;

    function createBroker(
        uint _brokerId,
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine
    )
    senderIsController("user")
    public
    {
        users[_email] = keccak256(_password);
        Broker storage broker = brokers[_brokerId];
        broker.name = _name;
        broker.email = _email;
        broker.brokerId = _brokerId;
        broker.contactPhone = _contactPhone;
        broker.addressLine = _addressLine;
    }

    function getBroker(uint _brokerId)
    senderIsController("user")
    public
    view
    returns (bytes32, bytes32, bytes32, bytes32)
    {
        return (brokers[_brokerId].name, brokers[_brokerId].email, brokers[_brokerId].contactPhone, brokers[_brokerId].addressLine);
    }
}
