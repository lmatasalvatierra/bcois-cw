pragma solidity ^0.4.23;

library DataHelper {
    enum Stage { Active, Cancelled, Expired }

    enum UserType { Owner, Carrier, Broker }

    struct Endorsement {
        bytes32 name;
        string description;
    }

    struct CoI {
        uint certificateNumber;
        uint ownerId;
        uint brokerId;
        uint effectiveDate;
        bytes16[5] policyIds;
        uint numPolicies;
        bytes16 certificateUUID;
    }

    struct Policy {
        uint policyNumber;
        uint ownerId;
        bytes32 name;
        DataHelper.Stage status;
        uint effectiveDate;
        uint expirationDate;
        uint carrierId;
        bytes16 policyUUID;
    }
}
