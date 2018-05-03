pragma solidity ^0.4.23;
import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/CoiDB.sol";

contract Coi is Controller {
    function createCoi(uint ownerId, uint effectiveDate) senderIsManager public returns (uint certificateId) {
        address coiDb = obtainDBContract("coiDB");
        certificateId = CoiDB(coiDb).createCoi(ownerId, effectiveDate);
        return certificateId;
    }

    function getCoi(uint certificateNumber) senderIsManager public view
        returns(uint _certificateNumber, uint _ownerId, uint _effectiveDate)
    {
        address coiDb = obtainDBContract("coiDB");

        (_certificateNumber, _ownerId, _effectiveDate) = CoiDB(coiDb).getCoi(certificateNumber);
        return (_certificateNumber, _ownerId, _effectiveDate);
    }

    function addPolicy(uint certificateNumber, uint policyNumber) senderIsManager public {
        address coiDb = obtainDBContract("coiDB");

        CoiDB(coiDb).addPolicy(certificateNumber, policyNumber);
    }

    function getPoliciesOfCoi(uint certificateNumber) senderIsManager public view returns (uint[5] policies) {
        address coiDb = obtainDBContract("coiDB");

        policies = CoiDB(coiDb).getPoliciesOfCoi(certificateNumber);
    }
}
