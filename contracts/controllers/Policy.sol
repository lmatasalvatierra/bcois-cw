
pragma solidity ^0.4.23;
import "./Controller.sol";
import "../libraries/DataHelper.sol";
import "../databases/PolicyDB.sol";

contract Policy is Controller {

    mapping (uint => uint) carrierPolicies;

    function createPolicy(
        uint _ownerId,
        bytes32 _name,
        uint _effectiveDate,
        uint _expirationDate,
        uint carrierId,
        bytes16 _policyUUID
    )
        senderIsManager public returns (uint result)
    {
        address policydb = obtainDBContract("policyDB");
        result = PolicyDB(policydb).createPolicy(_ownerId, _name, _effectiveDate, _expirationDate, carrierId, _policyUUID);
        carrierPolicies[result] = carrierId;
        return result;
    }

    function isPolicyOfCarrier(uint policyNumber, uint carrierId) senderIsManager public view returns (bool) {
        return (carrierPolicies[policyNumber] == carrierId);
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
      uint _policyNumber,
      uint _ownerId,
      bytes32 _name,
      DataHelper.Stage _status,
      uint _effectiveDate,
      uint _expirationDate,
      uint _carrierId
    )
    {
        address policydb = obtainDBContract("policyDB");

        (_policyNumber,
         _ownerId,
         _name,
         _status,
         _effectiveDate,
         _expirationDate,
         _carrierId
        ) = PolicyDB(policydb).getPolicy(policyNumber);
        return (_policyNumber, _ownerId, _name, _status, _effectiveDate, _expirationDate, _carrierId);
    }

    function isPolicyValid(uint _policyNumber, uint _ownerId) senderIsManager public view returns (bool) {
        address policydb = obtainDBContract("policyDB");
        uint ownerId;
        DataHelper.Stage status;

        (, ownerId , , status, , , ) = PolicyDB(policydb).getPolicy(_policyNumber);
        return (_ownerId == ownerId && status == DataHelper.Stage.Active);
    }

    function cancelPolicy(uint _policyNumber) senderIsManager public {
        address policydb = obtainDBContract("policyDB");

        PolicyDB(policydb).updateStatus(_policyNumber, DataHelper.Stage.Cancelled);
    }

    function changePolicyToExpired() senderIsManager public {
        address policydb = obtainDBContract("policyDB");
        PolicyDB(policydb).changeToExpired();
    }
}
