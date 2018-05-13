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
        uint effectiveDate;
        uint numPolicies;
        bytes16[5] policyIds;
        bytes16 certificateUUID;
        bytes16 ownerUUID;
        bytes16 brokerUUID;
    }

    struct Policy {
        uint policyNumber;
        bytes32 name;
        DataHelper.Stage status;
        uint effectiveDate;
        uint expirationDate;
        bytes16 carrierUUID;
        bytes16 policyUUID;
        bytes16 ownerUUID;
    }
}
