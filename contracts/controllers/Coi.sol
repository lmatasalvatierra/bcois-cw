pragma solidity ^0.4.23;
import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/CoiDB.sol";

contract Coi is Controller {
    mapping (uint => uint) brokerCertificates;

    function createCoi(uint ownerId, uint effectiveDate, uint brokerId, bytes16 certificateUUID) senderIsManager public returns (uint certificateId) {
        address coiDb = obtainDBContract("coiDB");
        certificateId = CoiDB(coiDb).createCoi(ownerId, effectiveDate, brokerId, certificateUUID);
        brokerCertificates[certificateId] = brokerId;
        return certificateId;
    }

    function getCoi(uint certificateNumber) senderIsManager public view
        returns(bytes16 _certificateUUID, uint _ownerId, uint _brokerId, uint _effectiveDate)
    {
        address coiDb = obtainDBContract("coiDB");

        (_certificateUUID, _ownerId, _brokerId, _effectiveDate) = CoiDB(coiDb).getCoi(certificateNumber);
        return (_certificateUUID, _ownerId, _brokerId, _effectiveDate);
    }

    function getCoi(bytes16 certificateUUID) senderIsManager public view
        returns(bytes16 _certificateUUID, uint _ownerId, uint _brokerId, uint _effectiveDate)
    {
        address coiDb = obtainDBContract("coiDB");

        uint certificateNumber = CoiDB(coiDb).getCoiNumber(certificateUUID);
        (_certificateUUID, _ownerId, _brokerId, _effectiveDate) = CoiDB(coiDb).getCoi(certificateNumber);
        return (_certificateUUID, _ownerId, _brokerId, _effectiveDate);
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

    function isCoiOfBroker(uint certificateNumber, uint brokerId) senderIsManager public view returns (bool) {
        return (brokerCertificates[certificateNumber] == brokerId);
    }

    function getNumCertificates() public view returns (uint numCertificates) {
        address coiDb = obtainDBContract("coiDB");

        numCertificates = CoiDB(coiDb).getNumCertificates();
    }
}
