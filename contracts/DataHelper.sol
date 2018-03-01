pragma solidity ^0.4.4;

library DataHelper {
    enum Stage { Active, Cancelled, Expired }

    enum Permission { Admin, Carrier, Broker, User }

    struct Endorsement {
        bytes32 name;
        string description;
    }
}
