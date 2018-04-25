pragma solidity ^0.4.4;
import "./Controller.sol";
import "./DataHelper.sol";
import "./CoiDB.sol";

contract Coi is Controller {
    function createCoi(uint ownerId) senderIsManager public returns (uint result) {
        address coiDb = obtainDBContract("coiDB");
        result = CoiDB(coiDb).createCoi(ownerId);
        return result;
    }

    function getCoi(uint certificateNumber) senderIsManager public view
        returns(uint _certificateNumber, uint _ownerId)
    {
        address coiDb = obtainDBContract("coiDB");

        (_certificateNumber, _ownerId) = CoiDB(coiDb).getCoi(certificateNumber);
        return (_certificateNumber, _ownerId);
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
