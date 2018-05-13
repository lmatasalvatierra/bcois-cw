pragma solidity ^0.4.23;

import "./Database.sol";

contract BrokerDB is Database {
    struct Broker {
        bytes32 email;
        bytes32 name;
        bytes32 contactPhone;
        bytes32 addressLine;
    }

    mapping (bytes16 => Broker) brokers;

    function createBroker(
        bytes16 _userUUID,
        bytes32 _email,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine
    )
    senderIsController("user")
    public
    {
        Broker storage broker = brokers[_userUUID];
        broker.email = _email;
        broker.name = _name;
        broker.contactPhone = _contactPhone;
        broker.addressLine = _addressLine;
    }

    function getBroker(bytes16 _brokerUUID) senderIsController("user")
    public
    view
    returns (bytes32, bytes32, bytes32, bytes32)
    {
        return (brokers[_brokerUUID].email , brokers[_brokerUUID].name, brokers[_brokerUUID].contactPhone, brokers[_brokerUUID].addressLine);
    }
}
