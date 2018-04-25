pragma solidity ^0.4.4;

import "./Database.sol";
import "./DataHelper.sol";

contract CoiDB is Database {
    uint numCertificates;
    mapping (uint => DataHelper.CoI) cois;

    function createCoi(uint _ownerId) senderIsController("coi") public returns (uint id)
    {
        numCertificates++;
        DataHelper.CoI storage coi = cois[numCertificates];
        coi.certificateNumber = numCertificates;
        coi.ownerId = _ownerId;
        return numCertificates;
    }

    function getCoi(uint certificateNumber) senderIsController("coi") public view returns(uint, uint)
    {
        DataHelper.CoI storage coi = cois[certificateNumber];
        return (coi.certificateNumber, coi.ownerId);
    }

    function addPolicy(uint certificateNumber, uint policyNumber) senderIsController("coi") public {
        cois[certificateNumber].policyIds[cois[certificateNumber].numPolicies] = policyNumber;
        cois[certificateNumber].numPolicies += 1;
    }

    function getPoliciesOfCoi(uint certificateNumber) senderIsController("coi") public view returns (uint[5]) {
        return cois[certificateNumber].policyIds;
    }
}
