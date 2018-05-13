pragma solidity ^0.4.23;

import "./Database.sol";
import "../libraries/DataHelper.sol";

contract CoiDB is Database {
    uint numCertificates;
    mapping (uint => DataHelper.CoI) cois;
    mapping (bytes16 => uint) uuidToId;

    function createCoi(bytes16 _ownerUUID, uint _effectiveDate, bytes16 _brokerUUID, bytes16 _certificateUUID) senderIsController("coi") public returns (uint)
    {
        numCertificates++;
        uuidToId[_certificateUUID] = numCertificates;
        DataHelper.CoI storage coi = cois[numCertificates];
        coi.certificateNumber = numCertificates;
        coi.ownerUUID = _ownerUUID;
        coi.brokerUUID = _brokerUUID;
        coi.effectiveDate = _effectiveDate;
        coi.certificateUUID = _certificateUUID;
        return numCertificates;
    }

    function getCoi(uint certificateNumber) senderIsController("coi") public view returns(bytes16, bytes16, bytes16, uint)
    {
        DataHelper.CoI storage coi = cois[certificateNumber];
        require(coi.ownerUUID != 0, "The certificate does not exist");
        return (coi.certificateUUID, coi.ownerUUID, coi.brokerUUID, coi.effectiveDate);
    }

    function addPolicy(uint certificateNumber, bytes16 policyUUID) senderIsController("coi") public {
        cois[certificateNumber].policyIds[cois[certificateNumber].numPolicies] = policyUUID;
        cois[certificateNumber].numPolicies += 1;
    }

    function getPoliciesOfCoi(uint certificateNumber) senderIsController("coi") public view returns (bytes16[5]) {
        return cois[certificateNumber].policyIds;
    }

    function getNumCertificates() senderIsController("coi") public view returns (uint) {
        return numCertificates;
    }

    function getCoiNumber(bytes16 _certificateUUID) senderIsController("coi") public view returns (uint){
        return uuidToId[_certificateUUID];
    }
}
