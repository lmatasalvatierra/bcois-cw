
pragma solidity ^0.4.23;
import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/PolicyDB.sol";

contract Policy is Controller {

    mapping (uint => bytes16) carrierPolicies;

    function createPolicy(
        bytes16 _ownerUUID,
        bytes32 _name,
        uint _effectiveDate,
        uint _expirationDate,
        bytes16 _carrierUUID,
        bytes16 _policyUUID
    )
        senderIsManager public returns (uint result)
    {
        address policydb = obtainDBContract("policyDB");
        result = PolicyDB(policydb).createPolicy(_ownerUUID, _name, _effectiveDate, _expirationDate, _carrierUUID, _policyUUID);
        carrierPolicies[result] = _carrierUUID;
        return result;
    }

    function isPolicyOfCarrier(uint policyNumber, bytes16 _carrierUUID) senderIsManager public view returns (bool) {
        return (carrierPolicies[policyNumber] == _carrierUUID);
    }

    function getNumPolicies() senderIsManager public view returns (uint numPolicies) {
        address policydb = obtainDBContract("policyDB");
        numPolicies = PolicyDB(policydb).getNumPolicies();
    }

    function getPolicy(
      uint policyNumber
    )
    senderIsManager
    public view
    returns(
      bytes16 _policyUUID,
      bytes16 _ownerUUID,
      bytes16 _carrierUUID,
      bytes32 _name,
      DataHelper.Stage _status,
      uint _effectiveDate,
      uint _expirationDate
    )
    {
        address policydb = obtainDBContract("policyDB");

        (_policyUUID,
         _ownerUUID,
         _carrierUUID,
         _name,
         _status,
         _effectiveDate,
         _expirationDate
        ) = PolicyDB(policydb).getPolicy(policyNumber);
    }

    function getPolicy(
      bytes16 policyUUID
    )
    senderIsManager
    public view
    returns(
      bytes16 _ownerUUID,
      bytes16 _carrierUUID,
      bytes32 _name,
      DataHelper.Stage _status,
      uint _effectiveDate,
      uint _expirationDate
    )
    {
        address policydb = obtainDBContract("policyDB");
        uint policyNumber;
        policyNumber = PolicyDB(policydb).getPolicyNumber(policyUUID);

        (,
         _ownerUUID,
         _carrierUUID,
         _name,
         _status,
         _effectiveDate,
         _expirationDate
        ) = PolicyDB(policydb).getPolicy(policyNumber);
    }

    function isPolicyValid(bytes16 _policyUUID, bytes16 _ownerUUID) senderIsManager public view returns (bool) {
        address policydb = obtainDBContract("policyDB");
        bytes16 ownerUUID;
        DataHelper.Stage status;
        uint policyNumber;

        policyNumber = PolicyDB(policydb).getPolicyNumber(_policyUUID);
        (, ownerUUID, , , status, , ) = PolicyDB(policydb).getPolicy(policyNumber);
        return (ownerUUID == _ownerUUID && status == DataHelper.Stage.Active);
    }

    function cancelPolicy(bytes16 _policyUUID) senderIsManager public {
        address policydb = obtainDBContract("policyDB");
        uint policyNumber;
        policyNumber = PolicyDB(policydb).getPolicyNumber(_policyUUID);

        PolicyDB(policydb).updateStatus(policyNumber, DataHelper.Stage.Cancelled);
    }

    function changePolicyToExpired() senderIsManager public {
        address policydb = obtainDBContract("policyDB");
        PolicyDB(policydb).changeToExpired();
    }
}
