pragma solidity ^0.4.4;

library DataHelper {
    enum Stage { Active, Cancelled, Expired }

    struct Endorsement {
        bytes32 name;
        string description;
    }
}
