pragma solidity ^0.4.23;

import "./Database.sol";
import "../libraries/DataHelper.sol";

contract CoiDB is Database {
    uint numCertificates;
    mapping (uint => DataHelper.CoI) cois;

    function createCoi(uint _ownerId, uint _effectiveDate, uint _brokerId) senderIsController("coi") public returns (uint)
    {
        numCertificates++;
        DataHelper.CoI storage coi = cois[numCertificates];
        coi.certificateNumber = numCertificates;
        coi.ownerId = _ownerId;
        coi.brokerId = _brokerId;
        coi.effectiveDate = _effectiveDate;
        return numCertificates;
    }

    function getCoi(uint certificateNumber) senderIsController("coi") public view returns(uint, uint, uint, uint)
    {
        DataHelper.CoI storage coi = cois[certificateNumber];
        return (coi.certificateNumber, coi.ownerId, coi.brokerId, coi.effectiveDate);
    }

    function addPolicy(uint certificateNumber, uint policyNumber) senderIsController("coi") public {
        cois[certificateNumber].policyIds[cois[certificateNumber].numPolicies] = policyNumber;
        cois[certificateNumber].numPolicies += 1;
    }

    function getPoliciesOfCoi(uint certificateNumber) senderIsController("coi") public view returns (uint[5]) {
        return cois[certificateNumber].policyIds;
    }

    function getNumCertificates() senderIsController("coi") public view returns (uint) {
        return numCertificates;
    }
}
