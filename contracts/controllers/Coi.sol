pragma solidity ^0.4.23;
import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/CoiDB.sol";

contract Coi is Controller {
    mapping (uint => bytes16) brokerCertificates;

    function createCoi(bytes16 ownerUUID, uint effectiveDate, bytes16 brokerUUID, bytes16 certificateUUID) senderIsManager public returns (uint certificateId) {
        address coiDb = obtainDBContract("coiDB");
        certificateId = CoiDB(coiDb).createCoi(ownerUUID, effectiveDate, brokerUUID, certificateUUID);
        brokerCertificates[certificateId] = brokerUUID;
        return certificateId;
    }

    function getCoi(uint certificateNumber) senderIsManager public view
        returns(bytes16 _certificateUUID, bytes16 _ownerUUID, bytes16 _brokerUUID, uint _effectiveDate)
    {
        address coiDb = obtainDBContract("coiDB");

        (_certificateUUID, _ownerUUID, _brokerUUID, _effectiveDate) = CoiDB(coiDb).getCoi(certificateNumber);
    }

    function getCoi(bytes16 certificateUUID) senderIsManager public view
        returns(bytes16 _certificateUUID, bytes16 _ownerUUID, bytes16 _brokerUUID, uint _effectiveDate)
    {
        address coiDb = obtainDBContract("coiDB");

        uint certificateNumber = CoiDB(coiDb).getCoiNumber(certificateUUID);
        (_certificateUUID, _ownerUUID, _brokerUUID, _effectiveDate) = CoiDB(coiDb).getCoi(certificateNumber);
    }

    function addPolicy(uint certificateNumber, bytes16 policyUUID) senderIsManager public {
        address coiDb = obtainDBContract("coiDB");

        CoiDB(coiDb).addPolicy(certificateNumber, policyUUID);
    }

    function getPoliciesOfCoi(bytes16 certificateUUID) senderIsManager public view returns (bytes16[5] policies) {
        address coiDb = obtainDBContract("coiDB");

        uint certificateNumber = CoiDB(coiDb).getCoiNumber(certificateUUID);
        policies = CoiDB(coiDb).getPoliciesOfCoi(certificateNumber);
    }

    function isCoiOfBroker(uint certificateNumber, bytes16 _brokerUUID) senderIsManager public view returns (bool) {
        return (brokerCertificates[certificateNumber] == _brokerUUID);
    }

    function getNumCertificates() public view returns (uint numCertificates) {
        address coiDb = obtainDBContract("coiDB");

        numCertificates = CoiDB(coiDb).getNumCertificates();
    }
}
