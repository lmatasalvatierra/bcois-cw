pragma solidity ^0.4.4;

library DataHelper {
    enum Stage { Active, Cancelled, Expired }

    enum Permission { User, Owner, Agency, Government, Admin }

    struct Endorsement {
        bytes32 name;
        string description;
    }

    struct CoI {
        uint certificateNumber;
        uint ownerId;
        DataHelper.Stage status;
        uint effectiveDate;
        uint expirationDate;
    }
}
